//
//  ImageStorageService.swift
//  RecipeReady
//
//  Handles downloading and saving images to local storage.
//

import Foundation
import UIKit

final class ImageStorageService {
    static let shared = ImageStorageService()

    private let fileManager = FileManager.default

    // Custom URLSession with no cache for image downloads
    private lazy var downloadSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = nil  // Disable caching for downloads
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()

    private init() {}
    
    /// Downloads an image from a URL and saves it locally.
    /// Returns the local filename/path relative to Documents directory.
    func saveImage(from url: URL) async throws -> String {
        MemoryDebugger.shared.log("🖼️ Before image download")

        let (data, response) = try await downloadSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        print("📥 Downloaded image: \(data.count / 1024) KB from \(url.lastPathComponent)")
        MemoryDebugger.shared.log("🖼️ After download, before UIImage creation")

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        MemoryDebugger.shared.log("🖼️ After UIImage creation, before save")

        let filename = try saveImage(image)

        MemoryDebugger.shared.log("🖼️ After image saved to disk")

        return filename
    }
    
    /// Saves a UIImage locally.
    /// Returns the local filename/path relative to Documents directory.
    func saveImage(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        let filename = UUID().uuidString + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        try data.write(to: fileURL)
        
        return filename
    }
    
    /// Deletes an image with the given filename.
    func deleteImage(filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Gets the full URL for a local filename.
    func getFileURL(filename: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(filename)
    }
    
    private func getDocumentsDirectory() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
