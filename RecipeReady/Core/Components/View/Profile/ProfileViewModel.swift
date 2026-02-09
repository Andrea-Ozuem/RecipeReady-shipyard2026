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
    
    // MARK: - Published Properties
    @Published var appVersion: String = ""
    @Published var buildNumber: String = ""
    
    // MARK: - Init
    init() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.buildNumber = build
        }
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
