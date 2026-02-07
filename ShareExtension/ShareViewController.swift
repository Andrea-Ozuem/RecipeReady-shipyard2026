//
//  ShareViewController.swift
//  ShareExtension
//
//  Entry point for the Share Extension that receives videos from Instagram/TikTok.
//

import UIKit
import UniformTypeIdentifiers
import AVFoundation

/// Share Extension view controller that handles incoming video shares.
class ShareViewController: UIViewController {
    
    private let appGroupManager = AppGroupManager.shared
    private let audioExtractor = AudioExtractor.shared
    
    // MARK: - Debug Mode
    /// Set to true to see all incoming data from the share sheet
    private let debugMode = false
    
    // MARK: - UI Elements
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "RecipeReady"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Processing video..."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Debug UI elements
    private lazy var debugTextView: UITextView = {
        let textView = UITextView()
        textView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.isEditable = false
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var debugTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📦 Incoming Share Data"
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if debugMode {
            setupDebugUI()
            inspectSharedContent()
        } else {
            setupUI()
            processSharedContent()
        }
    }
    
    // MARK: - Debug UI Setup
    
    private func setupDebugUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(debugTitleLabel)
        containerView.addSubview(debugTextView)
        containerView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            debugTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            debugTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            debugTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            debugTextView.topAnchor.constraint(equalTo: debugTitleLabel.bottomAnchor, constant: 12),
            debugTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            debugTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            debugTextView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -12),
            
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
    
    private func inspectSharedContent() {
        var debugInfo = ""
        
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            debugTextView.text = "❌ No extension items found"
            return
        }
        
        debugInfo += "📥 ITEMS: \(extensionItems.count)\n"
        debugInfo += "━━━━━━━━━━━━━━━━━━━━━━\n\n"
        
        for (itemIndex, item) in extensionItems.enumerated() {
            // Check for attributed title/content
            if let attributedTitle = item.attributedTitle {
                debugInfo += "📝 Title: \(attributedTitle.string)\n\n"
            }
            if let attributedContentText = item.attributedContentText {
                debugInfo += "📄 Content:\n\(attributedContentText.string)\n\n"
            }
            
            // Check attachments
            guard let attachments = item.attachments else {
                debugInfo += "⚠️ No attachments\n"
                continue
            }
            
            debugInfo += "📎 Attachments: \(attachments.count)\n\n"
            
            for (attachIndex, attachment) in attachments.enumerated() {
                debugInfo += "── Attachment \(attachIndex + 1) ──\n"
                debugInfo += "Types available:\n"
                
                for typeId in attachment.registeredTypeIdentifiers {
                    debugInfo += "  • \(typeId)\n"
                }
                debugInfo += "\n"
                
                // Load ALL content for each registered type
                for typeId in attachment.registeredTypeIdentifiers {
                    loadRawContent(attachment, typeId: typeId, attachIndex: attachIndex)
                }
            }
        }
        
        debugTextView.text = debugInfo
    }
    
    private func loadRawContent(_ attachment: NSItemProvider, typeId: String, attachIndex: Int) {
        attachment.loadItem(forTypeIdentifier: typeId) { [weak self] item, error in
            DispatchQueue.main.async {
                var content = "\n📦 [\(typeId)]:\n"
                
                if let error = error {
                    content += "Error: \(error.localizedDescription)\n"
                } else if let url = item as? URL {
                    content += "URL: \(url.absoluteString)\n"
                } else if let text = item as? String {
                    content += "String: \(text)\n"
                } else if let data = item as? Data {
                    content += "Data: \(data.count) bytes\n"
                    // Try to decode as string
                    if let str = String(data: data, encoding: .utf8) {
                        let preview = String(str.prefix(500))
                        content += "Preview:\n\(preview)\n"
                    }
                } else if let dict = item as? [String: Any] {
                    content += "Dict: \(dict)\n"
                } else if let item = item {
                    content += "Type: \(type(of: item))\n"
                    content += "Value: \(item)\n"
                } else {
                    content += "nil\n"
                }
                
                content += "────────────────\n"
                self?.debugTextView.text += content
            }
        }
    }
    
    // Legacy method kept for compatibility
    private func loadAttachmentContent(_ attachment: NSItemProvider, index: Int, completion: @escaping (String) -> Void) {
        // Try URL first
        if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { item, error in
                if let url = item as? URL {
                    completion("URL: \(url.absoluteString)")
                } else if let error = error {
                    completion("URL Error: \(error.localizedDescription)")
                }
            }
        }
        
        // Try plain text
        if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, error in
                if let text = item as? String {
                    completion("Text: \(text)")
                }
            }
        }
        
        // Try video/movie
        if attachment.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.movie.identifier) { item, error in
                if let url = item as? URL {
                    completion("Video URL: \(url.absoluteString)")
                } else if let data = item as? Data {
                    completion("Video Data: \(data.count) bytes")
                }
            }
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(statusLabel)
        containerView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            
            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    // MARK: - Content Processing
    
    private func processSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            showError("No content found")
            return
        }
        
        // Look for video content
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                loadVideo(from: attachment)
                return
            }
            if attachment.hasItemConformingToTypeIdentifier(UTType.video.identifier) {
                loadVideo(from: attachment)
                return
            }
        }
        
        // No video found - check for URL (Instagram/TikTok share links)
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                loadURL(from: attachment)
                return
            }
        }
        
        showError("Please share a video from Instagram or TikTok")
    }
    
    private func loadVideo(from attachment: NSItemProvider) {
        attachment.loadItem(forTypeIdentifier: UTType.movie.identifier) { [weak self] item, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError("Failed to load video: \(error.localizedDescription)")
                    return
                }
                
                guard let url = item as? URL else {
                    self?.showError("Could not get video URL")
                    return
                }
                
                self?.extractAudio(from: url)
            }
        }
    }
    
    private func loadURL(from attachment: NSItemProvider) {
        attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let url = item as? URL else {
                    self.showError("Could not process shared content")
                    return
                }
                
                // Start Apify caption extraction
                self.extractCaptionFromURL(url)
            }
        }
    }
    
    private func extractCaptionFromURL(_ url: URL) {
        updateStatus("Extracting caption...")
        
        Task {
            do {
                let (caption, videoUrl, thumbnailUrl) = try await ApifyService.shared.extractCaption(from: url)
                
                // Debug logging
                print("[ShareExtension] 📥 Apify returned - caption: \(caption?.prefix(50) ?? "nil")..., videoUrl: \(videoUrl ?? "nil"), thumb: \(thumbnailUrl ?? "nil")")
                
                // Create payload with caption and video URL for fallback
                let payload = ExtractionPayload(
                    audioFileName: nil,  // No audio for caption-only mode
                    caption: caption ?? "No caption available for this video.",
                    sourceURL: url.absoluteString,
                    remoteVideoURL: videoUrl  // Pass video URL for audio fallback
                )
                
                print("[ShareExtension] 💾 Saving payload with remoteVideoURL: \(payload.remoteVideoURL ?? "nil")")
                
                try appGroupManager.savePayload(payload)
                
                await MainActor.run {
                    self.completeSuccessfully()
                }
            } catch {
                await MainActor.run {
                    // Fallback to default text on error
                    self.handleApifyError(error, sourceURL: url)
                }
            }
        }
    }
    
    private func handleApifyError(_ error: Error, sourceURL: URL) {
        // For MVP: Save with default text and continue
        let payload = ExtractionPayload(
            audioFileName: nil,
            caption: "Could not extract caption. Please try again or use a different video.",
            sourceURL: sourceURL.absoluteString
        )
        
        do {
            try appGroupManager.savePayload(payload)
            completeSuccessfully()
        } catch {
            showError("Failed to save: \(error.localizedDescription)")
        }
    }
    
    private func extractAudio(from videoURL: URL) {
        updateStatus("Extracting audio...")
        
        Task {
            do {
                // Get App Group pending directory for output
                guard let pendingDir = appGroupManager.pendingDirectoryURL else {
                    throw AppGroupError.containerNotFound
                }
                
                // Create pending directory if needed
                if !FileManager.default.fileExists(atPath: pendingDir.path) {
                    try FileManager.default.createDirectory(at: pendingDir, withIntermediateDirectories: true)
                }
                
                // Extract audio
                let audioURL = try await audioExtractor.extractAudio(from: videoURL, to: pendingDir)
                
                // Create and save payload
                let payload = ExtractionPayload(
                    audioFileName: audioURL.lastPathComponent,
                    caption: nil, // TODO: Extract caption if available
                    sourceURL: nil
                )
                
                try appGroupManager.savePayload(payload)
                
                await MainActor.run {
                    self.completeSuccessfully()
                }
            } catch {
                await MainActor.run {
                    self.showError("Failed to process video: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = message
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.statusLabel.text = message
            self.statusLabel.textColor = .systemRed
        }
        
        // Auto-dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.cancelTapped()
        }
    }
    
    private func completeSuccessfully() {
        activityIndicator.stopAnimating()
        statusLabel.text = "Recipe ready for extraction!"
        statusLabel.textColor = .systemGreen
        
        // Open main app
        openMainApp()
        
        // Complete extension
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.extensionContext?.completeRequest(returningItems: nil)
        }
    }
    
    private func openMainApp() {
        // Use URL scheme to open main app
        guard let url = URL(string: "recipeready://extract") else { return }
        
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url)
                return
            }
            responder = responder?.next
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        extensionContext?.cancelRequest(withError: NSError(
            domain: "com.recipeready.share",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "User cancelled"]
        ))
    }
}
