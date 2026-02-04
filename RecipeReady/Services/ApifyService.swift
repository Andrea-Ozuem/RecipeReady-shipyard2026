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

/// Response from Apify dataset items
struct ApifyDatasetItem: Codable {
    let caption: String?
    let videoUrl: String?
    let audioUrl: String?
    let ownerUsername: String?
    let ownerFullName: String?
    let likesCount: Int?
    let timestamp: String?
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
    private let apiToken = "" // TODO: Add API Token securely
    
    /// Actor ID for Instagram scraper
    private let actorId = "shu8hvrXbJbY3Eb9W"
    
    /// Base URL for Apify API
    private let baseURL = "https://api.apify.com/v2"
    
    /// Maximum time to wait for run completion (seconds)
    private let maxWaitTime: TimeInterval = 30
    
    /// Polling interval (seconds)
    private let pollInterval: TimeInterval = 2
    
    private init() {}
    
    // MARK: - Public API
    
    /// Extracts caption from an Instagram/TikTok URL
    /// - Parameter url: The social media URL
    /// - Returns: The caption text and optional video URL
    func extractCaption(from url: URL) async throws -> (caption: String?, videoUrl: String?) {
        // 1. Start actor run
        let runId = try await startActorRun(with: url)
        
        // 2. Poll for completion
        let datasetId = try await waitForCompletion(runId: runId)
        
        // 3. Fetch results
        let items = try await fetchDatasetItems(datasetId: datasetId)
        
        // 4. Extract caption from first item
        guard let firstItem = items.first else {
            print("[ApifyService] ⚠️ No items returned from dataset")
            return (nil, nil)
        }
        
        print("[ApifyService] ✅ Got item - caption: \(firstItem.caption?.prefix(50) ?? "nil")..., videoUrl: \(firstItem.videoUrl ?? "nil")")
        return (firstItem.caption, firstItem.videoUrl)
    }
    
    // MARK: - Private Methods
    
    /// Starts a new Apify actor run
    private func startActorRun(with url: URL) async throws -> String {
        let endpoint = "\(baseURL)/acts/\(actorId)/runs?token=\(apiToken)"
        
        guard let requestURL = URL(string: endpoint) else {
            throw ApifyError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Input for Instagram scraper
        let input: [String: Any] = [
            "directUrls": [url.absoluteString],
            "resultsLimit": 1
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: input)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw ApifyError.networkError("Failed to start actor run")
        }
        
        let runResponse = try JSONDecoder().decode(ApifyRunResponse.self, from: data)
        return runResponse.data.id
    }
    
    /// Polls for run completion and returns dataset ID
    private func waitForCompletion(runId: String) async throws -> String {
        let endpoint = "\(baseURL)/actor-runs/\(runId)?token=\(apiToken)"
        
        guard let requestURL = URL(string: endpoint) else {
            throw ApifyError.invalidURL
        }
        
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < maxWaitTime {
            let (data, _) = try await URLSession.shared.data(from: requestURL)
            let runResponse = try JSONDecoder().decode(ApifyRunResponse.self, from: data)
            
            switch runResponse.data.status {
            case "SUCCEEDED":
                guard let datasetId = runResponse.data.defaultDatasetId else {
                    throw ApifyError.runFailed("No dataset ID")
                }
                return datasetId
                
            case "FAILED", "ABORTED", "TIMED-OUT":
                throw ApifyError.runFailed(runResponse.data.status)
                
            default:
                // Still running, wait and poll again
                try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
            }
        }
        
        throw ApifyError.timeout
    }
    
    /// Fetches items from a dataset
    private func fetchDatasetItems(datasetId: String) async throws -> [ApifyDatasetItem] {
        let endpoint = "\(baseURL)/datasets/\(datasetId)/items?token=\(apiToken)"
        
        guard let requestURL = URL(string: endpoint) else {
            throw ApifyError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: requestURL)
        
        // Debug: Log raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("[ApifyService] 📦 Raw dataset response: \(jsonString.prefix(1000))...")
        }
        
        return try JSONDecoder().decode([ApifyDatasetItem].self, from: data)
    }
}
