//
//  AppGroupManager.swift
//  RecipeReady
//
//  Manages shared storage between the main app and Share Extension via App Group.
//

import Foundation

/// Configuration constants for App Group.
enum AppGroupConfig {
    /// App Group identifier - must match entitlements
    static let identifier = "group.com.recipeready.shared"
    
    /// Directory name for pending extractions
    static let pendingDirectory = "pending"
    
    /// File name for the current extraction payload
    static let payloadFileName = "extraction_payload.json"
}

/// Payload passed from Share Extension to main app.
struct ExtractionPayload: Codable {
    let id: UUID
    let audioFileName: String?  // Optional for caption-only extraction
    let caption: String?
    let sourceURL: String?
    let remoteVideoURL: String?  // Video download URL from Apify for audio fallback
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        audioFileName: String? = nil,
        caption: String? = nil,
        sourceURL: String? = nil,
        remoteVideoURL: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.audioFileName = audioFileName
        self.caption = caption
        self.sourceURL = sourceURL
        self.remoteVideoURL = remoteVideoURL
        self.createdAt = createdAt
    }
}

/// Errors that can occur in App Group operations.
enum AppGroupError: LocalizedError {
    case containerNotFound
    case saveFailed(String)
    case loadFailed(String)
    case audioFileNotFound
    
    var errorDescription: String? {
        switch self {
        case .containerNotFound:
            return "App Group container not found. Ensure entitlements are configured."
        case .saveFailed(let reason):
            return "Failed to save payload: \(reason)"
        case .loadFailed(let reason):
            return "Failed to load payload: \(reason)"
        case .audioFileNotFound:
            return "Audio file not found in App Group container."
        }
    }
}

/// Manages data sharing between Share Extension and main app.
final class AppGroupManager {
    
    /// Shared instance for convenience.
    static let shared = AppGroupManager()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    // MARK: - Container Access
    
    /// Returns the App Group shared container URL.
    var containerURL: URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppGroupConfig.identifier)
    }
    
    /// Returns the pending extractions directory URL.
    var pendingDirectoryURL: URL? {
        containerURL?.appendingPathComponent(AppGroupConfig.pendingDirectory, isDirectory: true)
    }
    
    // MARK: - Payload Operations
    
    /// Saves an extraction payload to the shared container.
    /// - Parameter payload: The extraction payload to save.
    func savePayload(_ payload: ExtractionPayload) throws {
        guard let pendingDir = pendingDirectoryURL else {
            throw AppGroupError.containerNotFound
        }
        
        // Create pending directory if needed
        if !fileManager.fileExists(atPath: pendingDir.path) {
            try fileManager.createDirectory(at: pendingDir, withIntermediateDirectories: true)
        }
        
        // Encode and save payload
        let payloadURL = pendingDir.appendingPathComponent(AppGroupConfig.payloadFileName)
        do {
            let data = try JSONEncoder().encode(payload)
            try data.write(to: payloadURL)
        } catch {
            throw AppGroupError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Loads the pending extraction payload if available.
    /// - Returns: The extraction payload, or nil if none exists.
    func loadPendingPayload() -> ExtractionPayload? {
        guard let pendingDir = pendingDirectoryURL else { return nil }
        
        let payloadURL = pendingDir.appendingPathComponent(AppGroupConfig.payloadFileName)
        guard fileManager.fileExists(atPath: payloadURL.path) else { return nil }
        
        guard let data = try? Data(contentsOf: payloadURL),
              let payload = try? JSONDecoder().decode(ExtractionPayload.self, from: data) else {
            return nil
        }
        
        return payload
    }
    
    /// Returns the URL for the audio file from a payload.
    /// - Parameter payload: The extraction payload.
    /// - Returns: URL of the audio file, or nil if no audio file.
    func audioFileURL(for payload: ExtractionPayload) -> URL? {
        guard let audioFileName = payload.audioFileName else { return nil }
        return pendingDirectoryURL?.appendingPathComponent(audioFileName)
    }
    
    /// Checks if audio file exists for a payload.
    /// - Parameter payload: The extraction payload.
    /// - Returns: True if the audio file exists.
    func audioFileExists(for payload: ExtractionPayload) -> Bool {
        guard let audioURL = audioFileURL(for: payload) else { return false }
        return fileManager.fileExists(atPath: audioURL.path)
    }
    
    // MARK: - Cleanup
    
    /// Removes the pending payload and associated audio file.
    func cleanupPendingPayload() throws {
        guard let pendingDir = pendingDirectoryURL else { return }
        
        // Remove payload file
        let payloadURL = pendingDir.appendingPathComponent(AppGroupConfig.payloadFileName)
        if fileManager.fileExists(atPath: payloadURL.path) {
            try fileManager.removeItem(at: payloadURL)
        }
    }
    
    /// Removes a specific audio file.
    /// - Parameter payload: The payload whose audio file should be removed.
    func cleanupAudioFile(for payload: ExtractionPayload) throws {
        guard let audioURL = audioFileURL(for: payload) else { return }
        if fileManager.fileExists(atPath: audioURL.path) {
            try fileManager.removeItem(at: audioURL)
        }
    }
    
    /// Removes all files in the pending directory.
    func cleanupAll() throws {
        guard let pendingDir = pendingDirectoryURL else { return }
        if fileManager.fileExists(atPath: pendingDir.path) {
            try fileManager.removeItem(at: pendingDir)
        }
    }
}
