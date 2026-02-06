//
//  RecipeExtractionService.swift
//  RecipeReady
//
//  Service for extracting recipes from audio + caption via backend API.
//  Currently stubbed for local development (backend deferred).
//

import Foundation

/// Response from the recipe extraction API.
struct RecipeExtractionResponse: Codable {
    let ingredients: [Ingredient]
    let steps: [CookingStep]
    let sourceLink: String?
    let imageURL: String?
    let confidenceScore: Double
    let title: String?
    
    // Metadata
    let servings: Int?
    let prepTime: Int?
    let cookingTime: Int?
    let restingTime: Int?
    let difficulty: String?
}

/// Errors that can occur during recipe extraction.
enum RecipeExtractionError: LocalizedError {
    case noAudioFile
    case networkError(String)
    case parsingError(String)
    case serverError(Int, String)
    
    var errorDescription: String? {
        switch self {
        case .noAudioFile:
            return "No audio file provided for extraction."
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Failed to parse response: \(message)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        }
    }
}

/// Protocol for recipe extraction service.
protocol RecipeExtractionServiceProtocol {
    func extractRecipe(
        audioURL: URL?,
        caption: String?,
        remoteVideoURL: String?,
        thumbnailURL: String?
    ) async throws -> RecipeExtractionResponse
}

/// Service for extracting recipes - now using Gemini AI.
final class RecipeExtractionService: RecipeExtractionServiceProtocol {
    
    /// Shared instance for convenience.
    static let shared = RecipeExtractionService()
    
    /// Gemini service dependency
    private let geminiService = GeminiService.shared
    
    /// Audio extractor for video processing
    private let audioExtractor = AudioExtractor.shared
    
    private init() {}
    
    // MARK: - Public API
    
    func extractRecipe(
        audioURL: URL?,
        caption: String?,
        remoteVideoURL: String?,
        thumbnailURL: String?
    ) async throws -> RecipeExtractionResponse {
        
        // 1. Analyze Caption (always try this first)
        var captionResult: GeminiRecipeResult?
        if let caption = caption, !caption.isEmpty {
            captionResult = try? await geminiService.parseRecipe(from: caption)
        }
        
        // 2. Check completeness of caption result
        if let result = captionResult {
            // Golden path: Caption has both ingredients and steps
            if !result.ingredients.isEmpty && !result.steps.isEmpty {
                return mapToResponse(result, imageURL: thumbnailURL)
            }
            
            // If caption has ingredients but no video available -> Return what we have
            if !result.ingredients.isEmpty && remoteVideoURL == nil {
                return mapToResponse(result, imageURL: thumbnailURL)
            }
        }
        
        // 3. Audio Fallback/Augmentation
        // Only ignore if we have no video URL
        guard let videoURLString = remoteVideoURL,
              let videoURL = URL(string: videoURLString) else {
             // If we have a partial caption result, return it. Otherwise fail.
            if let result = captionResult, result.hasRecipe {
                return mapToResponse(result, imageURL: thumbnailURL)
            }
            throw RecipeExtractionError.parsingError("No recipe found in caption and no video URL available.")
        }
        
        // Download & Extract Audio
        let localVideoURL = try await downloadVideo(from: videoURL)
        defer { try? FileManager.default.removeItem(at: localVideoURL) }
        
        let audioURL = try await audioExtractor.extractAudio(from: localVideoURL)
        defer { audioExtractor.cleanup(audioURL: audioURL) }
        
        let audioData = try Data(contentsOf: audioURL)
        let audioResult = try await geminiService.parseRecipeFromAudio(audioData)
        
        // 4. Merge Results
        // Prioritize caption for ingredients (usually better quality/structure)
        // Prioritize audio for steps (if caption lacks them)
        
        var finalIngredients = audioResult.ingredients
        if let captionIngredients = captionResult?.ingredients, !captionIngredients.isEmpty {
            finalIngredients = captionIngredients
        }
        
        var finalSteps = audioResult.steps
        if let captionSteps = captionResult?.steps, !captionSteps.isEmpty {
            finalSteps = captionSteps
        } else if finalSteps.isEmpty && !finalIngredients.isEmpty {
             // If we have ingredients but NO steps even after audio,
             // create a placeholder step so the recipe is valid.
             finalSteps = [CookingStep(order: 1, instruction: "Follow the instructions in the video.")]
        }

        // Merge Metadata (prefer caption, fallback to audio)
        let serv = captionResult?.servings ?? audioResult.servings
        let prep = captionResult?.prepTime ?? audioResult.prepTime
        let cook = captionResult?.cookingTime ?? audioResult.cookingTime
        let rest = captionResult?.restingTime ?? audioResult.restingTime
        let diff = captionResult?.difficulty ?? audioResult.difficulty
        let title = captionResult?.title ?? audioResult.title
        
        // Calculate combined confidence
        let confidence = max(captionResult?.confidenceScore ?? 0, audioResult.confidenceScore)
        
        return RecipeExtractionResponse(
            ingredients: finalIngredients,
            steps: finalSteps,
            sourceLink: nil,
            imageURL: thumbnailURL,
            confidenceScore: confidence,
            title: title,
            servings: serv,
            prepTime: prep,
            cookingTime: cook,
            restingTime: rest,
            difficulty: diff
        )
    }
    
    private func mapToResponse(_ result: GeminiRecipeResult, imageURL: String?) -> RecipeExtractionResponse {
        return RecipeExtractionResponse(
            ingredients: result.ingredients,
            steps: result.steps,
            sourceLink: nil,
            imageURL: imageURL,
            confidenceScore: result.confidenceScore,
            title: result.title,
            servings: result.servings,
            prepTime: result.prepTime,
            cookingTime: result.cookingTime,
            restingTime: result.restingTime,
            difficulty: result.difficulty
        )
    }
    
    // MARK: - Private Helpers
    
    /// Downloads video from URL to a temporary file
    private func downloadVideo(from url: URL) async throws -> URL {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw RecipeExtractionError.networkError("Failed to download video")
        }
        
        // Move to a known location with proper extension
        let destURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        try FileManager.default.moveItem(at: tempURL, to: destURL)
        
        return destURL
    }
}

