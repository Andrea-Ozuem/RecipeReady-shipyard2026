//
//  SetReminderSheet.swift
//  RecipeReady
//
//  Sheet for setting cooking reminders for recipes.
//

import SwiftUI
import SwiftData

struct SetReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("areNotificationsEnabled") private var areNotificationsEnabled: Bool = true

    let recipe: Recipe

    @State private var selectedDate: Date
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    init(recipe: Recipe) {
        self.recipe = recipe
        // Initialize with existing reminder or default to 1 hour from now
        let defaultDate = recipe.reminderDate ?? Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        _selectedDate = State(initialValue: defaultDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)

            ScrollView {
                VStack(spacing: 24) {
                    // Notifications Disabled Warning
                    if !areNotificationsEnabled {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notifications Disabled")
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                Text("Enable notifications in Profile settings to set reminders.")
                                    .font(.captionMeta)
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    }

                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.primaryBlue)

                        Text("Set Cooking Reminder")
                            .font(.heading2.bold())
                            .foregroundColor(.textPrimary)

                        Text("When do you want to cook \(recipe.title)?")
                            .font(.bodyRegular)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 8)

                    // Date Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date & Time")
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 24)

                        DatePicker(
                            "",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .padding(.horizontal, 24)
                    }

                    // Quick Time Suggestions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Options")
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 24)

                        VStack(spacing: 12) {
                            quickOptionButton(title: "Tonight at 6 PM", date: tonightAt6PM)
                            quickOptionButton(title: "Tomorrow at 12 PM", date: tomorrowAtNoon)
                            quickOptionButton(title: "Tomorrow at 6 PM", date: tomorrowAt6PM)
                        }
                        .padding(.horizontal, 24)
                    }

                    // Prep Time Info
                    if let prepTime = recipe.prepTime {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.primaryBlue)
                            Text("Prep time: \(prepTime) min")
                                .font(.captionMeta)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, 24)
                    }

                    // Cancel Reminder Button (if reminder exists)
                    if recipe.reminderDate != nil {
                        Button(action: cancelReminder) {
                            Text("Cancel Reminder")
                                .font(.bodyRegular)
                                .foregroundColor(.red)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 100) // Space for fixed button
            }

            Spacer()

            // Save Button
            Button(action: saveReminder) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                } else {
                    Text(recipe.reminderDate != nil ? "Update Reminder" : "Set Reminder")
                        .font(.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
            }
            .background(areNotificationsEnabled ? Color.primaryGreen : Color.gray)
            .cornerRadius(28)
            .disabled(isSaving || !areNotificationsEnabled)
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(Color.white)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Quick Option Dates

    private var tonightAt6PM: Date? {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 18
        components.minute = 0
        let date = Calendar.current.date(from: components)
        return date ?? Date()
    }

    private var tomorrowAtNoon: Date? {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return nil }
        var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 12
        components.minute = 0
        return Calendar.current.date(from: components)
    }

    private var tomorrowAt6PM: Date? {
        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) else { return nil }
        var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 18
        components.minute = 0
        return Calendar.current.date(from: components)
    }

    // MARK: - Helper Views

    private func quickOptionButton(title: String, date: Date?) -> some View {
        Button(action: {
            if let date = date, date > Date() {
                selectedDate = date
            }
        }) {
            HStack {
                Text(title)
                    .font(.bodyRegular)
                    .foregroundColor(.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding()
            .background(Color.inputBackground)
            .cornerRadius(12)
        }
        .disabled(date == nil || (date ?? Date()) <= Date())
        .opacity((date == nil || (date ?? Date()) <= Date()) ? 0.5 : 1.0)
    }

    // MARK: - Actions

    private func saveReminder() {
        guard areNotificationsEnabled else {
            errorMessage = "Please enable notifications in Profile settings to set reminders."
            showError = true
            return
        }

        guard selectedDate > Date() else {
            errorMessage = "Please select a future date and time."
            showError = true
            return
        }

        isSaving = true

        Task {
            do {
                // Cancel existing reminder if any
                if recipe.reminderNotificationId != nil {
                    try await RecipeReminderService.shared.cancelReminder(for: recipe)
                }

                // Schedule new reminder
                let notificationId = try await RecipeReminderService.shared.scheduleReminder(for: recipe, at: selectedDate)

                // Update recipe
                await MainActor.run {
                    recipe.reminderDate = selectedDate
                    recipe.reminderNotificationId = notificationId
                    recipe.updatedAt = Date()

                    try? modelContext.save()

                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func cancelReminder() {
        Task {
            do {
                try await RecipeReminderService.shared.cancelReminder(for: recipe)

                await MainActor.run {
                    recipe.reminderDate = nil
                    recipe.reminderNotificationId = nil
                    recipe.updatedAt = Date()

                    try? modelContext.save()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Recipe.self, configurations: config)

    let sampleRecipe = Recipe(
        title: "Lemon Garlic Pasta",
        ingredients: [],
        steps: [],
        prepTime: 15,
        cookingTime: 20
    )

    return SetReminderSheet(recipe: sampleRecipe)
        .modelContainer(container)
}

