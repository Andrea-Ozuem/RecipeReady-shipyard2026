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
    let confidenceScore: Double
    let title: String?
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
        remoteVideoURL: String?
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
    
    /// Extracts recipe from caption first, with audio fallback.
    func extractRecipe(
        audioURL: URL?,
        caption: String?,
        remoteVideoURL: String?
    ) async throws -> RecipeExtractionResponse {
        
        // 1. Try caption first (fastest path)
        if let caption = caption, !caption.isEmpty {
            let result = try await geminiService.parseRecipe(from: caption)
            
            if result.hasRecipe {
                return RecipeExtractionResponse(
                    ingredients: result.ingredients,
                    steps: result.steps,
                    sourceLink: nil,
                    confidenceScore: result.confidenceScore,
                    title: result.title
                )
            }
        }
        
        // 2. Fallback: Download video → Extract audio → Send to Gemini
        guard let videoURLString = remoteVideoURL,
              let videoURL = URL(string: videoURLString) else {
            throw RecipeExtractionError.parsingError("No recipe found in caption and no video URL available for audio fallback.")
        }
        
        // Download video
        let localVideoURL = try await downloadVideo(from: videoURL)
        
        defer {
            // Cleanup temp video file
            try? FileManager.default.removeItem(at: localVideoURL)
        }
        
        // Extract audio from video
        let audioURL = try await audioExtractor.extractAudio(from: localVideoURL)
        
        defer {
            // Cleanup temp audio file
            audioExtractor.cleanup(audioURL: audioURL)
        }
        
        // Read audio data
        let audioData = try Data(contentsOf: audioURL)
        
        // Send to Gemini for transcription + recipe extraction
        let result = try await geminiService.parseRecipeFromAudio(audioData)
        
        guard result.hasRecipe else {
            throw RecipeExtractionError.parsingError("No recipe found in caption or audio. Try a different video with clear recipe instructions.")
        }
        
        return RecipeExtractionResponse(
            ingredients: result.ingredients,
            steps: result.steps,
            sourceLink: nil,
            confidenceScore: result.confidenceScore,
            title: result.title
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

