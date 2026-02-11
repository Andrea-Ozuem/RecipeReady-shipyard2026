//
//  RecipeReadyApp.swift
//  RecipeReady
//
//  Created by Ozuem Andrea Chukwunomswe  on 31/01/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    // Store the recipe ID to navigate to when notification is tapped
    var recipeIdToOpen: UUID?

    // Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Called when user taps on notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Extract recipe ID from notification
        if let recipeIdString = userInfo["recipeId"] as? String,
           let recipeId = UUID(uuidString: recipeIdString) {
            // Store the recipe ID to be handled by the app
            recipeIdToOpen = recipeId

            // Post notification to trigger navigation
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenRecipeFromNotification"),
                object: nil,
                userInfo: ["recipeId": recipeId]
            )
        }

        completionHandler()
    }
}

@main
struct RecipeReadyApp: App {
    @State private var extractionManager = ExtractionManager()
    @StateObject private var revenueCatService = RevenueCatService.shared

    init() {
        // Configure RevenueCat on launch
        RevenueCatService.shared.configure()

        // Configure URLCache with smaller memory footprint
        let cache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,  // 20 MB memory cache
            diskCapacity: 100 * 1024 * 1024     // 100 MB disk cache
        )
        URLCache.shared = cache

        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
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