//
//  ProfileViewModel.swift
//  RecipeReady
//
//  Created by RecipeReady Team on 09/02/2026.
//

import SwiftUI
import StoreKit
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - App Storage
    @AppStorage("measurementSystem") var measurementSystem: MeasurementSystem = .metric
    @AppStorage("areNotificationsEnabled") var areNotificationsEnabled: Bool = true
    @AppStorage("userName") var userName: String = ""
    
    // MARK: - Published Properties
    @Published var appVersion: String = ""
    @Published var buildNumber: String = ""
    @Published var activeSheet: ProfileSheet?
    
    // MARK: - Computed Properties
    var userInitial: String {
        return String(userName.prefix(1)).uppercased()
    }
    
    // MARK: - Init
    init() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.buildNumber = build
        }
        
        // Generate random username if empty
        if userName.isEmpty {
            userName = "Chef_\(Int.random(in: 1000...9999))"
        }
    }
    
    // MARK: - Actions
    func updateName(_ newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            userName = trimmed
        }
        activeSheet = nil
    }
    
    // MARK: - Actions
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func contactSupport() {
         // Implement mailto or web support link
        if let url = URL(string: "mailto:support@recipeready.com") {
             UIApplication.shared.open(url)
        }
    }
    
    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://gist.githubusercontent.com/Andrea-Ozuem/efb42f6a0a3e0789f6d344f664fd3849/raw/a7124b2b38ac7d7b5053da679d90515318d8b55b/privacy_policy.md") {
            UIApplication.shared.open(url)
        }
    }
    
    func openTermsOfUse() {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Settings Enum
enum MeasurementSystem: String, CaseIterable, Identifiable {
    case metric = "Metric"
    case imperial = "Imperial" // US System
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .metric: return "ruler"
        case .imperial: return "ruler.fill"
        }
    }
}
// MARK: - Sheets
enum ProfileSheet: Identifiable {
    case editProfile
    
    var id: Int {
        hashValue
    }
}
