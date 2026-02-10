//
//  Recipe+Reminder.swift
//  RecipeReady
//
//  Extension for Recipe to handle reminder-related operations.
//

import Foundation

extension Recipe {
    /// Cancel the reminder for this recipe if one exists
    func cancelReminderIfNeeded() async {
        guard reminderNotificationId != nil else { return }
        
        do {
            try await RecipeReminderService.shared.cancelReminder(for: self)
            reminderDate = nil
            reminderNotificationId = nil
        } catch {
            print("Error canceling reminder for recipe \(title): \(error)")
        }
    }
    
    /// Check if this recipe has an active reminder
    var hasActiveReminder: Bool {
        guard let reminderDate = reminderDate else { return false }
        return reminderDate > Date()
    }
}

