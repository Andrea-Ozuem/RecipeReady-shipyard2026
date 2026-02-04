//
//  Config.swift
//  RecipeReady
//
//  Configuration and API keys. DO NOT commit this file to version control.
//

import Foundation

/// App configuration - API keys and settings
enum Config {
    
    /// Gemini AI API key
    /// Get yours at: https://aistudio.google.com/apikey
    static let geminiAPIKey = Secrets.geminiApiKey
    
    /// Gemini API endpoint
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    
    /// Gemini model to use
    /// Verified working: gemini-flash-lite-latest
    static let geminiModel = "gemini-flash-lite-latest"
}
