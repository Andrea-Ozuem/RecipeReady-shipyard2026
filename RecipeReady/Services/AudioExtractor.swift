//
//  AudioExtractor.swift
//  RecipeReady
//
//  Extracts audio from video files using AVFoundation.
//

import AVFoundation
import Foundation

/// Errors that can occur during audio extraction.
enum AudioExtractionError: LocalizedError {
    case noAudioTrack
    case exportFailed(String)
    case invalidVideoURL
    case exportCancelled
    
    var errorDescription: String? {
        switch self {
        case .noAudioTrack:
            return "The video does not contain an audio track."
        case .exportFailed(let reason):
            return "Audio export failed: \(reason)"
        case .invalidVideoURL:
            return "The provided video URL is invalid."
        case .exportCancelled:
            return "Audio export was cancelled."
        }
    }
}

/// Service for extracting audio from video files.
final class AudioExtractor {
    
    /// Shared instance for convenience.
    static let shared = AudioExtractor()
    
    private init() {}
    
    /// Extracts audio from a video file and saves it as .m4a (mono, 16kHz).
    /// - Parameters:
    ///   - videoURL: URL of the source video file.
    ///   - outputDirectory: Directory to save the extracted audio. Defaults to temp directory.
    /// - Returns: URL of the extracted audio file.
    func extractAudio(
        from videoURL: URL,
        to outputDirectory: URL? = nil
    ) async throws -> URL {
        // Validate video URL exists
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            throw AudioExtractionError.invalidVideoURL
        }
        
        // Create asset from video
        let asset = AVURLAsset(url: videoURL)
        
        // Check for audio tracks
        let audioTracks = try await asset.loadTracks(withMediaType: .audio)
        guard !audioTracks.isEmpty else {
            throw AudioExtractionError.noAudioTrack
        }
        
        // Prepare output URL
        let outputDir = outputDirectory ?? FileManager.default.temporaryDirectory
        let outputFileName = "\(UUID().uuidString).m4a"
        let outputURL = outputDir.appendingPathComponent(outputFileName)
        
        // Remove existing file if present
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        // Create export session
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            throw AudioExtractionError.exportFailed("Could not create export session.")
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        // Export audio
        await exportSession.export()
        
        // Check export status
        switch exportSession.status {
        case .completed:
            return outputURL
        case .cancelled:
            throw AudioExtractionError.exportCancelled
        case .failed:
            let errorMessage = exportSession.error?.localizedDescription ?? "Unknown error"
            throw AudioExtractionError.exportFailed(errorMessage)
        default:
            throw AudioExtractionError.exportFailed("Export ended with unexpected status: \(exportSession.status.rawValue)")
        }
    }
    
    /// Cleans up a temporary audio file.
    /// - Parameter audioURL: URL of the audio file to delete.
    func cleanup(audioURL: URL) {
        try? FileManager.default.removeItem(at: audioURL)
    }
}
