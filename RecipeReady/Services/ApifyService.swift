//
//  ApifyService.swift
//  RecipeReady
//
//  Service for extracting Instagram/TikTok captions via Apify API.
//

import Foundation

/// Response from Apify actor run creation
struct ApifyRunResponse: Codable {
    let data: ApifyRunData
}

struct ApifyRunData: Codable {
    let id: String
    let status: String
    let defaultDatasetId: String?
}

/// Video metadata from TikTok scraper
struct ApifyVideoMeta: Codable {
    let coverUrl: String?
    let duration: Int?
}

/// Response from Apify dataset items
struct ApifyDatasetItem: Codable {
    let caption: String?
    let videoUrl: String?
    let audioUrl: String?
    let displayUrl: String?
    let thumbnailUrl: String?
    let ownerUsername: String?
    let ownerFullName: String?
    let likesCount: Int?
    let timestamp: String?
    
    // TikTok specific fields
    let text: String?
    let cover: String?
    let mediaUrls: [String]?
    let videoMeta: ApifyVideoMeta?
}

/// Errors that can occur during Apify operations
enum ApifyError: LocalizedError {
    case invalidURL
    case networkError(String)
    case runFailed(String)
    case timeout
    case noCaption
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Instagram/TikTok URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .runFailed(let status):
            return "Apify run failed: \(status)"
        case .timeout:
            return "Request timed out"
        case .noCaption:
            return "No caption found for this video"
        }
    }
}

/// Service for extracting captions from Instagram/TikTok via Apify
final class ApifyService {
    
    static let shared = ApifyService()
    
    // MARK: - Configuration
    
    /// Apify API token
    private let apiToken = Secrets.apifyApiKey
    
    /// Actor ID for Instagram scraper
    private let instagramActorId = "shu8hvrXbJbY3Eb9W"
    
    /// Actor ID for TikTok scraper
    private let tiktokActorId = "clockworks~free-tiktok-scraper"
    
    /// Base URL for Apify API
    private let baseURL = "https://api.apify.com/v2"
    
    /// Maximum time to wait for run completion (seconds)
    private let maxWaitTime: TimeInterval = 60 // Increased wait time for video download
    
    /// Polling interval (seconds)
    private let pollInterval: TimeInterval = 2
    
    private init() {}
    
    // MARK: - Public API
    
    /// Extracts caption from an Instagram/TikTok URL
    /// - Parameter url: The social media URL
    /// - Returns: The caption text, video URL, and thumbnail URL
    func extractCaption(from url: URL) async throws -> (caption: String?, videoUrl: String?, thumbnailUrl: String?) {
        // 1. Start actor run
        let runId = try await startActorRun(with: url)
        
        // 2. Poll for completion
        let datasetId = try await waitForCompletion(runId: runId)
        
        // 3. Fetch results
        let items = try await fetchDatasetItems(datasetId: datasetId)
        
        // 4. Extract caption from first item
        guard let firstItem = items.first else {
            print("[ApifyService] ⚠️ No items returned from dataset")
            return (nil, nil, nil)
        }
        
        // Normalize fields based on source
        // Instagram: caption, displayUrl/thumbnailUrl
        // TikTok: text, cover
        
        let caption = firstItem.caption ?? firstItem.text
        
        // Prefer displayUrl (full res) -> videoMeta.coverUrl (TikTok Scraper) -> thumbnailUrl -> cover
        var image = firstItem.displayUrl ?? firstItem.thumbnailUrl ?? firstItem.cover
        
        if let tiktokCover = firstItem.videoMeta?.coverUrl {
            image = tiktokCover
        }
        
        // Video URL handling
        // TikTok (free-tiktok-scraper): Use 'mediaUrls' (first item is usually the video)
        // Instagram/Legacy: Use 'videoUrl'
        var video = firstItem.videoUrl
        
        if let mediaUrls = firstItem.mediaUrls, let firstMedia = mediaUrls.first {
             video = firstMedia
        }
        
        print("[ApifyService] ✅ Got item - caption: \(caption?.prefix(50) ?? "nil")..., videoUrl: \(video ?? "nil"), thumb: \(image ?? "nil")")
        return (caption, video, image)
    }
    
    // MARK: - Private Methods
    
    /// Starts a new Apify actor run
    private func startActorRun(with url: URL) async throws -> String {
        let isTikTok = url.host?.contains("tiktok.com") == true
        let actorId = isTikTok ? tiktokActorId : instagramActorId
        
        print("[ApifyService] 🚀 Starting actor run for: \(url.absoluteString)")
        print("[ApifyService] 🎭 Actor: \(actorId)")
        
        let endpoint = "\(baseURL)/acts/\(actorId)/runs?token=\(apiToken)"
        
        guard let requestURL = URL(string: endpoint) else {
            throw ApifyError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Input payload
        var input: [String: Any] = [:]
        
        if isTikTok {
            // Clockworks Free TikTok Scraper input
            // Based on user provided schema: "postURLs", "shouldDownloadVideos": true
            input = [
                "postURLs": [url.absoluteString],
                "resultsPerPage": 1,
                "shouldDownloadVideos": true,
                "shouldDownloadCovers": true,
                "shouldDownloadSubtitles": false,
                "shouldDownloadSlideshowImages": false
            ]
        } else {
            // Instagram Scraper input
            input = [
                "directUrls": [url.absoluteString],
                "resultsLimit": 1
            ]
        }
        
        // Log Input
        if let inputData = try? JSONSerialization.data(withJSONObject: input, options: .prettyPrinted),
           let inputString = String(data: inputData, encoding: .utf8) {
            print("[ApifyService] 📥 Input Payload:\n\(inputString)")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: input)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "unknown"
            print("[ApifyService] ❌ Start run failed. Status: \( (response as? HTTPURLResponse)?.statusCode ?? -1 )")
            print("[ApifyService] ❌ Response Body: \(errorBody)")
            throw ApifyError.networkError("Failed to start actor run")
        }
        
        let runResponse = try JSONDecoder().decode(ApifyRunResponse.self, from: data)
        print("[ApifyService] ✅ Run started. ID: \(runResponse.data.id)")
        return runResponse.data.id
    }
    
    /// Polls for run completion and returns dataset ID
    private func waitForCompletion(runId: String) async throws -> String {
        let endpoint = "\(baseURL)/actor-runs/\(runId)?token=\(apiToken)"
        
        guard let requestURL = URL(string: endpoint) else {
            throw ApifyError.invalidURL
        }
        
        let startTime = Date()
        print("[ApifyService] ⏳ Waiting for completion (Max: \(maxWaitTime)s)...")
        
        while Date().timeIntervalSince(startTime) < maxWaitTime {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            let runResponse = try JSONDecoder().decode(ApifyRunResponse.self, from: data)
            
            print("[ApifyService] 🔄 Status: \(runResponse.data.status)")
            
            switch runResponse.data.status {
            case "SUCCEEDED":
                guard let datasetId = runResponse.data.defaultDatasetId else {
                    throw ApifyError.runFailed("No dataset ID")
                }
                print("[ApifyService] ✅ Run SUCCEEDED. Dataset ID: \(datasetId)")
                return datasetId
                
            case "FAILED", "ABORTED", "TIMED-OUT":
                print("[ApifyService] ❌ Run FAILED with status: \(runResponse.data.status)")
                throw ApifyError.runFailed(runResponse.data.status)
                
            default:
                // Still running, wait and poll again
                try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
            }
        }
        
        print("[ApifyService] ❌ Timeout waiting for run")
        throw ApifyError.timeout
    }
    
    /// Fetches items from a dataset
    private func fetchDatasetItems(datasetId: String) async throws -> [ApifyDatasetItem] {
        let endpoint = "\(baseURL)/datasets/\(datasetId)/items?token=\(apiToken)"
        
        guard let requestURL = URL(string: endpoint) else {
            throw ApifyError.invalidURL
        }
        
        print("[ApifyService] 📦 Fetching dataset items...")
        let (data, _) = try await URLSession.shared.data(from: requestURL)
        
        // Debug: Log raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[ApifyService] 📄 Raw Dataset JSON:\n\(jsonString)")
        }
        
        return try JSONDecoder().decode([ApifyDatasetItem].self, from: data)
    }
}
