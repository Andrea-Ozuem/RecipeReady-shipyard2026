//
//  RecipeReadyApp.swift
//  RecipeReady
//
//  Created by Ozuem Andrea Chukwunomswe  on 31/01/2026.
//

import SwiftUI
import SwiftData

@main
struct RecipeReadyApp: App {
    @State private var extractionManager = ExtractionManager()
    @StateObject private var revenueCatService = RevenueCatService.shared
    
    init() {
        // Configure RevenueCat on launch
        RevenueCatService.shared.configure()
    }
    
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if revenueCatService.isPro {
                    ContentView()
                        .environment(extractionManager)
                        .environmentObject(revenueCatService)
                        .onAppear {
                            extractionManager.checkForPendingExtraction()
                        }
                } else if !hasCompletedOnboarding {
                    OnboardingContainerView()
                        .environmentObject(revenueCatService)
                } else {
                    // Hard paywall for users who finished onboarding but aren't pro (e.g. cancelled subscription)
                    PaywallView(viewModel: OnboardingViewModel()) // Create a temporary viewModel or refactor PaywallView to not need it for this state
                        .environmentObject(revenueCatService)
                }
            }
            .onOpenURL { url in
                 // Handle URL regardless of state, or maybe only if pro? 
                 // For now allow deep links to work but they might be behind paywall
                 extractionManager.handleURL(url)
            }
        }
        .modelContainer(for: [Recipe.self, Cookbook.self, ShoppingListRecipe.self, ShoppingListItem.self])
    }
}