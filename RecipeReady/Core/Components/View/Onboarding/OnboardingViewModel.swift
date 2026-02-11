import SwiftUI
import Combine

// MARK: - Onboarding Data Model
struct OnboardingData {
    var gender: String?
    var acquisitionSource: String?
    var triedOtherApps: Bool?
    var cookingFrequency: String?
    var decisionStruggleDuration: String?
    var userGoals: Set<String> = []
    var obstacles: Set<String> = []
    var recipeSources: Set<String> = []
    var dietaryPreferences: Set<String> = []
    var cookingPersona: CookingPersona?
    
    enum CookingPersona: String {
        case exploratory
        case strict
    }
}

// MARK: - Onboarding Step Enum
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case featuresOverview
    case gender
    case acquisitionSource
    case competitorUsage
    case commitmentChart
    case cookingFrequency
    case decisionStruggle
    case timeStats
    case goals
    case obstacles
    case reassurance
    case recipeSources
    case socialMediaSupport
    case dietaryPreferences
    case cookingPersona
    case personalizedValueProp
    case trustAndPrivacy
    case setupLoading
    case freeGift
    case cookbookIntro
    case trialInfo
    case notificationPermission
    case paywall
    
    var progress: Double {
        return Double(self.rawValue + 1) / Double(Self.allCases.count)
    }
    
    var showProgressBar: Bool {
        return true
    }
}

// MARK: - Onboarding View Model
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var data = OnboardingData()
    
    // Total steps count for progress calculation if needed explicitly
    var totalSteps: Int { OnboardingStep.allCases.count }
    
    // Navigation
    func next() {
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = nextStep
            }
        } else {
            // End of flow
            completeOnboarding()
        }
    }
    
    func previous() {
        if let prevStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = prevStep
            }
        }
    }
    
    func completeOnboarding() {
        // Handle completion
        print("Onboarding Completed with data: \(data)")
        
        // Save completion flag
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Here we would also save the user data to a backend or local persistence
        // For now, we trust the persistence layer will pick it up or we'd call a service
    }
    
    // MARK: - Selection Helpers
    
    func toggleGoal(_ goal: String) {
        if data.userGoals.contains(goal) {
            data.userGoals.remove(goal)
        } else {
            data.userGoals.insert(goal)
        }
    }
    
    func toggleObstacle(_ obstacle: String) {
        if data.obstacles.contains(obstacle) {
            data.obstacles.remove(obstacle)
        } else {
            data.obstacles.insert(obstacle)
        }
    }
    
    func setPersona(_ persona: OnboardingData.CookingPersona) {
        data.cookingPersona = persona
        next()
    }
}
