//
//  ExtractionManager.swift
//  RecipeReady
//
//  Manages recipe extraction flow and state.
//

import Foundation
import SwiftUI

@Observable
final class ExtractionManager {
    var state: ExtractionState = .idle
    
    // Store payload in memory for retries, so we can delete the file immediately
    private var pendingPayload: ExtractionPayload?
    
    // Legacy properties for compatibility during migration (computed from state)
    var isExtracting: Bool {
        if case .processing = state { return true }
        return false
    }
    
    var savedRecipe: Recipe? {
        if case .success(let recipe) = state { return recipe }
        return nil
    }
    
    var extractionError: Error? {
        if case .error(let error) = state { return error }
        return nil
    }
    
    private let extractionService = RecipeExtractionService.shared
    
    // MARK: - Actions
    
    func reset() {
        // If we're resetting, we should clean up any pending data
        cleanupPendingData()
        state = .idle
    }
    
    func dismiss() {
        // If we're dismissing, we should clean up any pending data
        cleanupPendingData()
        state = .idle
    }
    
    func retry() {
        // Try to use in-memory payload first
        if let payload = pendingPayload {
            startExtraction(with: payload)
        } else {
            // Fallback to checking disk (though usually it should be gone)
            checkForPendingExtraction()
        }
    }
    
    func startManualCreation() {
        // Placeholder for manual creation flow
        // In a real app, this might set a flag to show a different sheet
        print("Starting manual creation...")
        dismiss()
    }
    
    // MARK: - App Group Support
    
    func checkForPendingExtraction() {
        print("🔍 ExtractionManager: Checking for pending extractions...")
        guard let payload = AppGroupManager.shared.loadPendingPayload() else {
            return
        }
        
        print("📦 ExtractionManager: Found pending payload: \(payload.id)")
        
        // Store in memory for retry capability
        self.pendingPayload = payload
        
        // IMMEDIATE CLEANUP: Remove the file from disk so it doesn't survive app restart
        // This prevents the "loop" where old extractions keep reappearing
        try? AppGroupManager.shared.cleanupPendingPayload()
        
        startExtraction(with: payload)
    }
    
    private func startExtraction(with payload: ExtractionPayload) {
        Task {
            // Update state on main actor
            await MainActor.run {
                self.state = .processing
            }
            
            do {
                // Determine audio URL from payload if available
                let audioURL = AppGroupManager.shared.audioFileURL(for: payload)
                
                // Perform extraction
                let response = try await extractionService.extractRecipe(
                    audioURL: audioURL,
                    caption: payload.caption,
                    remoteVideoURL: payload.remoteVideoURL,
                    thumbnailURL: payload.thumbnailURL
                )
                
                // Convert response to Recipe model
                let newRecipe = Recipe(
                    title: response.title ?? "New Recipe",
                    ingredients: response.ingredients,
                    steps: response.steps,
                    sourceLink: payload.sourceURL,
                    sourceCaption: payload.caption,
                    imageURL: response.imageURL,
                    difficulty: response.difficulty,
                    prepTime: response.prepTime,
                    cookingTime: response.cookingTime,
                    restingTime: response.restingTime,
                    servings: response.servings,
                    confidenceScore: response.confidenceScore
                )
                
                // Cleanup audio file after successful extraction
                try? AppGroupManager.shared.cleanupAudioFile(for: payload)
                
                // Clear pending payload from memory as we're done
                self.pendingPayload = nil
                
                // Update state on main actor
                await MainActor.run {
                    self.state = .success(newRecipe)
                }
                
            } catch {
                print("❌ ExtractionManager: Extraction failed: \(error)")
                await MainActor.run {
                    // Convert to ExtractionError
                    let extractionError = ExtractionError(
                        title: "Extraction Failed",
                        message: error.localizedDescription,
                        icon: "exclamationmark.triangle"
                    )
                    self.state = .error(extractionError)
                }
            }
        }
    }
    
    // MARK: - URL Handling
    
    func handleURL(_ url: URL) {
        print("🔗 ExtractionManager: Handling URL: \(url)")
        // When app is opened via URL scheme (e.g. from Share Extension), check for new data
        checkForPendingExtraction()
    }
    
    // MARK: - Private Helpers
    
    private func cleanupPendingData() {
        if let payload = pendingPayload {
            try? AppGroupManager.shared.cleanupAudioFile(for: payload)
            pendingPayload = nil
        }
    }
}

// MARK: - Supporting Types

enum ExtractionState: Equatable {
    case idle
    case processing
    case success(Recipe)
    case error(ExtractionError)
}

struct ExtractionError: Error, Equatable {
    let title: String
    let message: String
    let icon: String
}
