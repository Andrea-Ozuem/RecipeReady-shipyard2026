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

        // Setup memory debugging
        setupMemoryMonitoring()
    }

    private func setupMemoryMonitoring() {
        // Configure URLCache with smaller memory footprint
        // Default is ~512MB memory, we'll reduce to 20MB
        let cache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,  // 20 MB memory cache
            diskCapacity: 100 * 1024 * 1024     // 100 MB disk cache
        )
        URLCache.shared = cache

        // Log initial state
        MemoryDebugger.shared.logDetailed("🚀 App Launch")

        // Monitor memory warnings
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("⚠️⚠️⚠️ MEMORY WARNING RECEIVED ⚠️⚠️⚠️")
            MemoryDebugger.shared.printSummary()

            // Clear URLCache on memory warning
            URLCache.shared.removeAllCachedResponses()
            print("🧹 Cleared URLCache due to memory warning")
        }

        // Log URLCache configuration
        print("🗄️ URLCache Configuration:")
        print("   Memory Capacity: \(cache.memoryCapacity / 1024 / 1024) MB")
        print("   Disk Capacity: \(cache.diskCapacity / 1024 / 1024) MB")
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
                    RevenueCatPaywallView(viewModel: OnboardingViewModel())
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