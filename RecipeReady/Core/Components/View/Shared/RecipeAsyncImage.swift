//
//  RecipeAsyncImage.swift
//  RecipeReady
//
//  Custom AsyncImage that properly handles both remote URLs and local file paths.
//

import SwiftUI

// Non-generic container for the shared URLSession
enum RecipeImageLoader {
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
}

struct RecipeAsyncImage<Content: View, Placeholder: View>: View {
    let imageURL: String?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?
    @State private var isLoading = true
    
    init(
        imageURL: String?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.imageURL = imageURL
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else if isLoading {
                placeholder()
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let imageURL = imageURL else {
            isLoading = false
            return
        }
        
        // Check if it's a remote URL
        if imageURL.hasPrefix("http://") || imageURL.hasPrefix("https://") {
            await loadRemoteImage(from: imageURL)
        } else {
            // Local file in Documents directory
            loadLocalImage(filename: imageURL)
        }
    }
    
    private func loadRemoteImage(from urlString: String) async {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        do {
            // Use custom session without cache
            let (data, _) = try await RecipeImageLoader.session.data(from: url)

            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.uiImage = image
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        } catch {
            print("⚠️ Failed to load remote image: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func loadLocalImage(filename: String) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        
        if let image = UIImage(contentsOfFile: fileURL.path) {
            self.uiImage = image
        } else {
            print("⚠️ Failed to load local image: \(filename)")
        }
        
        self.isLoading = false
    }
}

// Convenience initializer for simple cases
extension RecipeAsyncImage where Content == AnyView, Placeholder == AnyView {
    init(imageURL: String?) {
        self.init(
            imageURL: imageURL,
            content: { image in
                AnyView(image.resizable().aspectRatio(contentMode: .fill))
            },
            placeholder: {
                AnyView(Rectangle().fill(Color.gray.opacity(0.1)))
            }
        )
    }
}

