//
//  ExtractionManager.swift
//  RecipeReady
//
//  Manages the recipe extraction workflow between Share Extension and main app.
//

import Foundation
import SwiftUI

/// Friendly errors for UI display
enum ExtractionError: LocalizedError, Equatable {
    case network
    case noRecipeFound
    case timeout
    case unknown(String)
    
    var title: String {
        switch self {
        case .network: return "Connection Lost"
        case .noRecipeFound: return "The Chef is Confused"
        case .timeout: return "Taking Too Long"
        case .unknown: return "Something Went Wrong"
        }
    }
    
    var message: String {
        switch self {
        case .network: return "Please check your internet connection and try again."
        case .noRecipeFound: return "We couldn't find a recipe in this video. You can try another one or create it manually."
        case .timeout: return "The video is taking longer than expected to process. Please try again."
        case .unknown(let msg): return msg
        }
    }
    
    var icon: String {
        switch self {
        case .network: return "wifi.exclamationmark"
        case .noRecipeFound: return "text.magnifyingglass"
        case .timeout: return "clock.exclamationmark"
        case .unknown: return "exclamationmark.triangle.fill"
        }
    }
}

/// State of the extraction process.
enum ExtractionState: Equatable {
    case idle
    case processing
    case success(Recipe)
    case error(ExtractionError)
}

/// Observable manager for recipe extraction workflow.
@MainActor
@Observable
final class ExtractionManager {
    
    // MARK: - Published Properties
    
    var state: ExtractionState = .idle
    var currentPayload: ExtractionPayload?
    var showingExtraction = false
    var showingManualCreation = false
    var manualRecipe: Recipe?
    
    // MARK: - Dependencies
    
    private let appGroupManager = AppGroupManager.shared
    private let extractionService = RecipeExtractionService.shared
    
    // MARK: - Initialization
    
    init() {}
    
    // MARK: - Public Methods
    
    /// Checks for pending extraction payloads on app launch.
    func checkForPendingExtraction() {
        guard let payload = appGroupManager.loadPendingPayload() else {
            return
        }
        
        guard state == .idle else { return }
        
        currentPayload = payload
        showingExtraction = true
        
        Task {
            await processExtraction(payload)
        }
    }
    
    /// Handles URL scheme callback from Share Extension.
    func handleURL(_ url: URL) {
        guard url.scheme == "recipeready",
              url.host == "extract" else {
            return
        }
        
        checkForPendingExtraction()
    }
    
    /// Retries the current extraction.
    func retry() {
        guard let payload = currentPayload else { return }
        
        Task {
            await processExtraction(payload)
        }
    }
    
    /// Starts the manual creation flow.
    func startManualCreation() {
        // 1. Dismiss extraction sheet
        showingExtraction = false
        cleanup()
        
        // 2. Prepare new recipe
        manualRecipe = Recipe(
            title: "",
            ingredients: [],
            steps: [],
            sourceLink: currentPayload?.sourceURL,
            sourceCaption: nil,
            confidenceScore: 1.0
        )
        
        // 3. Trigger manual creation sheet (with slight delay to allow dismissal)
        // Note: In a real app, we might use a coordinate or cleaner state management.
        // For MVP, we rely on SwiftUI's observation update cycle.
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            showingManualCreation = true
        }
    }
    
    /// Dismisses the extraction sheet and cleans up.
    func dismiss() {
        cleanup()
        showingExtraction = false
        state = .idle
        currentPayload = nil
    }
    
    // MARK: - Private Methods
    
    private func processExtraction(_ payload: ExtractionPayload) async {
        state = .processing
        
        // Check if we have content to process
        let hasAudio = appGroupManager.audioFileExists(for: payload)
        let hasCaption = payload.caption != nil && !payload.caption!.isEmpty
        let hasVideoURL = payload.remoteVideoURL != nil
        
        guard hasAudio || hasCaption || hasVideoURL else {
            state = .error(.noRecipeFound)
            return
        }
        
        do {
            // Get audio URL if available
            let audioURL = hasAudio ? appGroupManager.audioFileURL(for: payload) : nil
            
            // Call extraction service with caption and video URL for fallback
            let response = try await extractionService.extractRecipe(
                audioURL: audioURL,
                caption: payload.caption,
                remoteVideoURL: payload.remoteVideoURL
            )
            
            // Create recipe from response
            let recipe = Recipe(
                title: response.title ?? "Extracted Recipe",
                ingredients: response.ingredients,
                steps: response.steps,
                sourceLink: response.sourceLink ?? payload.sourceURL,
                sourceCaption: payload.caption,
                confidenceScore: response.confidenceScore
            )
            
            state = .success(recipe)
            
        } catch let error as RecipeExtractionError {
            // Map service errors to friendly UI errors
            switch error {
            case .networkError, .serverError:
                state = .error(.network)
            case .noAudioFile, .parsingError:
                state = .error(.noRecipeFound)
            }
        } catch {
            state = .error(.unknown(error.localizedDescription))
        }
    }
    
    private func cleanup() {
        guard let payload = currentPayload else { return }
        
        do {
            try appGroupManager.cleanupAudioFile(for: payload)
            try appGroupManager.cleanupPendingPayload()
        } catch {
            print("Cleanup error: \(error)")
        }
    }
}
