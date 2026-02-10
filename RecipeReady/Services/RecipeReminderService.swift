//
//  RecipeReminderService.swift
//  RecipeReady
//
//  Service for managing recipe cooking reminders using local notifications.
//

import Foundation
import UserNotifications

enum ReminderError: LocalizedError {
    case permissionDenied
    case invalidDate
    case schedulingFailed
    case notificationNotFound
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission is required to set reminders. Please enable notifications in Settings."
        case .invalidDate:
            return "Please select a future date and time for your reminder."
        case .schedulingFailed:
            return "Failed to schedule reminder. Please try again."
        case .notificationNotFound:
            return "Reminder notification not found."
        }
    }
}

final class RecipeReminderService {
    static let shared = RecipeReminderService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Schedule a reminder notification for a recipe
    /// - Parameters:
    ///   - recipe: The recipe to set a reminder for
    ///   - date: The date and time to send the notification
    /// - Returns: The notification identifier
    /// - Throws: ReminderError if scheduling fails
    func scheduleReminder(for recipe: Recipe, at date: Date) async throws -> String {
        // Validate date is in the future
        guard date > Date() else {
            throw ReminderError.invalidDate
        }
        
        // Check notification permission
        let status = await checkPermissionStatus()
        guard status == .authorized else {
            throw ReminderError.permissionDenied
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to cook \(recipe.title)!"
        
        // Build body with time information
        var bodyParts: [String] = []
        if let prepTime = recipe.prepTime {
            bodyParts.append("Prep Time: \(prepTime) min")
        }
        if let cookingTime = recipe.cookingTime {
            bodyParts.append("Cooking Time: \(cookingTime) min")
        }
        content.body = bodyParts.isEmpty ? "You wanted to make this today." : bodyParts.joined(separator: " | ")
        
        content.sound = .default
        content.categoryIdentifier = "RECIPE_REMINDER"
        
        // Add recipe ID to userInfo for deep linking
        content.userInfo = ["recipeId": recipe.id.uuidString]
        
        // Create trigger from date components
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Generate unique identifier
        let identifier = "recipe-reminder-\(recipe.id.uuidString)"
        
        // Create and schedule request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            return identifier
        } catch {
            throw ReminderError.schedulingFailed
        }
    }
    
    /// Cancel a scheduled reminder for a recipe
    /// - Parameter recipe: The recipe whose reminder should be canceled
    func cancelReminder(for recipe: Recipe) async throws {
        guard let notificationId = recipe.reminderNotificationId else {
            throw ReminderError.notificationNotFound
        }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationId])
    }
    
    /// Check the current notification permission status
    /// - Returns: The authorization status
    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    /// Get all pending notification requests
    /// - Returns: Array of pending notification requests
    func getPendingReminders() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    /// Request notification permission (if not already granted)
    /// - Returns: Whether permission was granted
    func requestPermission() async throws -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            throw ReminderError.permissionDenied
        }
    }
}

