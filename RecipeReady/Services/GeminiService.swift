//
//  GeminiService.swift
//  RecipeReady
//
//  Service for parsing recipes from text using Google Gemini AI.
//

import Foundation

/// Result from Gemini recipe parsing
struct GeminiRecipeResult {
    let hasRecipe: Bool
    let title: String?
    let ingredients: [Ingredient]
    let steps: [CookingStep]
    let confidenceScore: Double
    
    // Metadata
    let servings: Int?
    let prepTime: Int?        // in minutes
    let cookingTime: Int?     // in minutes
    let restingTime: Int?     // in minutes
    let difficulty: String?   // "Easy", "Medium", "Hard"
}

/// Errors that can occur during Gemini operations
enum GeminiError: LocalizedError {
    case invalidURL
    case networkError(String)
    case parsingError(String)
    case noContent
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Gemini API URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Failed to parse Gemini response: \(message)"
        case .noContent:
            return "No content in Gemini response"
        case .apiError(let message):
            return "Gemini API error: \(message)"
        }
    }
}

/// Service for extracting recipes from text using Gemini AI
final class GeminiService {
    
    static let shared = GeminiService()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Parses recipe from caption or transcript text
    /// - Parameter text: The caption or transcript to analyze
    /// - Returns: GeminiRecipeResult with extracted recipe or hasRecipe=false
    func parseRecipe(from text: String) async throws -> GeminiRecipeResult {
        let prompt = buildPrompt(for: text)
        let response = try await callGemini(prompt: prompt)
        return try parseResponse(response)
    }
    
    /// Parses recipe from audio data using Gemini multimodal
    /// - Parameter audioData: Audio data (M4A format)
    /// - Returns: GeminiRecipeResult with extracted recipe or hasRecipe=false
    func parseRecipeFromAudio(_ audioData: Data) async throws -> GeminiRecipeResult {
        let response = try await callGeminiWithAudio(audioData: audioData)
        return try parseResponse(response)
    }
    
    // MARK: - Private Methods
    
    private func buildPrompt(for text: String) -> String {
        """
        You are a recipe extraction assistant. Analyze the following social media caption and extract any recipe information.

        If the text contains ANY recipe information (ingredients OR cooking instructions), return ONLY valid JSON (no markdown, no code blocks):
        {
          "hasRecipe": true,
          "title": "Recipe name based on the content",
          "ingredients": [{"name": "ingredient name", "amount": "quantity or null", "section": "For the Sauce (optional)"}],
          "steps": [{"order": 1, "instruction": "Step description"}],
          "metadata": {
            "servings": 4,
            "prepTime": 15,
            "cookingTime": 30,
            "restingTime": null,
            "difficulty": "Easy"
          },
          "confidenceScore": 0.85
        }

        If the text does NOT contain any recipe information, return ONLY:
        {"hasRecipe": false}

        Extraction Rules:
        - Extract ONLY what is explicitly mentioned
        - If ingredients are listed in sections (e.g. "For the Sauce"), include the section header in the "section" field. If no section, set to null.
        - Ingredients: set "amount" to null if not specified, preserve vague amounts ("a handful", "to taste")
        - Servings: extract if mentioned ("serves 4"), infer from ingredients if reasonable, or null
        - Times (prepTime, cookingTime, restingTime): extract in minutes if mentioned, else null
        - Difficulty: infer from complexity - Easy (≤5 steps), Medium (6-10 steps), Hard (>10 steps). Use explicit mentions if present.
        - confidenceScore: 0.0-1.0 based on clarity
        - Return ONLY raw JSON, no markdown

        Caption:
        \"\"\"
        \(text)
        \"\"\"
        """
    }
    
    private func callGemini(prompt: String) async throws -> String {
        let endpoint = "\(Config.geminiBaseURL)/models/\(Config.geminiModel):generateContent?key=\(Config.geminiAPIKey)"
        
        guard let url = URL(string: endpoint) else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "maxOutputTokens": 1024
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError("Status \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Parse Gemini response structure
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.noContent
        }
        
        return text
    }
    
    /// Calls Gemini API with audio data for multimodal processing
    private func callGeminiWithAudio(audioData: Data) async throws -> String {
        let endpoint = "\(Config.geminiBaseURL)/models/\(Config.geminiModel):generateContent?key=\(Config.geminiAPIKey)"
        
        guard let url = URL(string: endpoint) else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build audio prompt
        let audioPrompt = """
        Listen to this audio from a cooking video and extract the recipe.
        
        If the audio contains ANY recipe information (ingredients OR cooking instructions), return ONLY valid JSON (no markdown, no code blocks):
        {
          "hasRecipe": true,
          "title": "Recipe name based on the content",
          "ingredients": [{"name": "ingredient name", "amount": "quantity or null", "section": "For the Sauce (optional)"}],
          "steps": [{"order": 1, "instruction": "Step description"}],
          "metadata": {
            "servings": 4,
            "prepTime": 15,
            "cookingTime": 30,
            "restingTime": null,
            "difficulty": "Easy"
          },
          "confidenceScore": 0.85
        }
        
        If the audio does NOT contain any recipe information, return ONLY:
        {"hasRecipe": false}
        
        Extraction Rules:
        - Extract ONLY what is explicitly mentioned
        - If ingredients are listed in sections (e.g. "For the Sauce"), include the section header in the "section" field
        - Ingredients: set "amount" to null if not specified
        - Servings: extract if mentioned, infer if reasonable, else null
        - Times: extract in minutes if mentioned, else null
        - Difficulty: infer from complexity
        - confidenceScore: 0.0-1.0 based on clarity
        - Return ONLY raw JSON, no markdown
        """
        
        // Encode audio as base64
        let base64Audio = audioData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": audioPrompt],
                        [
                            "inlineData": [
                                "mimeType": "audio/mp4",
                                "data": base64Audio
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.2,
                "maxOutputTokens": 1024
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError("Status \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Parse Gemini response structure
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.noContent
        }
        
        return text
    }
    
    private func parseResponse(_ response: String) throws -> GeminiRecipeResult {
        // Clean up response (remove markdown code blocks if present)
        var cleanedResponse = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedResponse.data(using: .utf8) else {
            throw GeminiError.parsingError("Cannot convert response to data")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GeminiError.parsingError("Invalid JSON structure")
        }
        
        let hasRecipe = json["hasRecipe"] as? Bool ?? false
        
        if !hasRecipe {
            return GeminiRecipeResult(
                hasRecipe: false,
                title: nil,
                ingredients: [],
                steps: [],
                confidenceScore: 0,
                servings: nil,
                prepTime: nil,
                cookingTime: nil,
                restingTime: nil,
                difficulty: nil
            )
        }
        
        // Parse ingredients
        var ingredients: [Ingredient] = []
        if let ingredientsList = json["ingredients"] as? [[String: Any]] {
            for item in ingredientsList {
                let name = item["name"] as? String ?? ""
                let amount = item["amount"] as? String
                let section = item["section"] as? String
                if !name.isEmpty {
                    ingredients.append(Ingredient(name: name, amount: amount, section: section))
                }
            }
        }
        
        // Parse steps
        var steps: [CookingStep] = []
        if let stepsList = json["steps"] as? [[String: Any]] {
            for item in stepsList {
                let order = item["order"] as? Int ?? (steps.count + 1)
                let instruction = item["instruction"] as? String ?? ""
                if !instruction.isEmpty {
                    steps.append(CookingStep(order: order, instruction: instruction))
                }
            }
        }
        
        // Parse metadata
        var servings: Int? = nil
        var prepTime: Int? = nil
        var cookingTime: Int? = nil
        var restingTime: Int? = nil
        var difficulty: String? = nil
        
        if let metadata = json["metadata"] as? [String: Any] {
            servings = metadata["servings"] as? Int
            prepTime = metadata["prepTime"] as? Int
            cookingTime = metadata["cookingTime"] as? Int
            restingTime = metadata["restingTime"] as? Int
            difficulty = metadata["difficulty"] as? String
        }
        
        return GeminiRecipeResult(
            hasRecipe: true,
            title: json["title"] as? String,
            ingredients: ingredients,
            steps: steps,
            confidenceScore: json["confidenceScore"] as? Double ?? 0.5,
            servings: servings,
            prepTime: prepTime,
            cookingTime: cookingTime,
            restingTime: restingTime,
            difficulty: difficulty
        )
    }
}
