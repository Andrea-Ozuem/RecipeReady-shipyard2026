import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeader(
                progress: viewModel.currentStep.progress,
                onBack: viewModel.previous,
                showBack: viewModel.currentStep != .welcome
            )
            
            // Content
            ZStack {
                stepView(for: viewModel.currentStep)
                    .background(Color.screenBackground)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Temporary Navigation Controls (Debug/Development)
            // Once we have actual buttons in the screens, this can be removed or hidden
            /*
            HStack {
                Button("Prev") { viewModel.previous() }
                    .disabled(viewModel.currentStep == .welcome)
                Spacer()
                Text(viewModel.currentStep.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button("Next") { viewModel.next() }
            }
            .padding()
            */
        }
        .background(Color.screenBackground.ignoresSafeArea())
    }
    
    @ViewBuilder
    func stepView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            WelcomeView(viewModel: viewModel)
            
        case .featuresOverview:
            FeaturesOverviewView(viewModel: viewModel)
            
        case .gender:
            GenericSelectionView(
                title: "What is your gender?",
                subtitle: "This helps us tailor your experience.",
                options: ["Male", "Female", "Prefer not to say"],
                selectedOption: $viewModel.data.gender,
                onNext: viewModel.next
            )
            
        case .acquisitionSource:
            GenericSelectionView(
                title: "Where did you hear about us?",
                subtitle: nil,
                options: ["App Store", "Instagram", "TikTok", "Friend/Family", "Other"],
                selectedOption: $viewModel.data.acquisitionSource,
                onNext: viewModel.next
            )
            
        case .competitorUsage:
             let options = ["Yes", "No"]
             let binding = Binding<String?>(
                 get: { viewModel.data.triedOtherApps.map { $0 ? "Yes" : "No" } },
                 set: { viewModel.data.triedOtherApps = ($0 == "Yes") }
             )
             GenericSelectionView(
                 title: "Have you tried other recipe extraction apps?",
                 subtitle: nil,
                 options: options,
                 selectedOption: binding,
                 onNext: viewModel.next
             )
            
        case .cookingFrequency:
            GenericSelectionView(
                title: "How many days do you cook per week?",
                subtitle: nil,
                options: ["1-2 days", "3-4 days", "5-6 days", "7+ days"],
                selectedOption: $viewModel.data.cookingFrequency,
                onNext: viewModel.next
            )
            
        case .decisionStruggle:
            GenericSelectionView(
                title: "How long do you struggle to decide what to cook?",
                subtitle: "Before you even start cooking.",
                options: ["Less than 5 mins", "5-15 mins", "15-30 mins", "More than 30 mins"],
                selectedOption: $viewModel.data.decisionStruggleDuration,
                onNext: viewModel.next
            )

        case .goals:
            GenericMultiSelectionView(
                title: "What are your goals?",
                subtitle: "Select all that apply",
                options: ["Save time cooking", "Eat healthier", "Try new recipes", "Organize my kitchen", "Reduce food waste"],
                selectedOptions: $viewModel.data.userGoals,
                onNext: viewModel.next
            )
            
        case .obstacles:
            GenericMultiSelectionView(
                title: "What's stopping you from reaching your goal?",
                subtitle: "Select all that apply",
                options: ["Lack of time", "Too many options", "Missing ingredients", "Lack of inspiration", "Meal prep is hard"],
                selectedOptions: $viewModel.data.obstacles,
                onNext: viewModel.next
            )
            
        case .recipeSources:
             GenericMultiSelectionView(
                title: "Where do you get your recipes from?",
                subtitle: nil,
                options: ["Instagram", "TikTok", "Websites/Blogs", "Cookbooks", "Youtube", "Family Recipes"],
                selectedOptions: $viewModel.data.recipeSources,
                onNext: viewModel.next
            )
            
        case .dietaryPreferences:
            GenericMultiSelectionView(
                title: "Do you follow a specific diet?",
                subtitle: nil,
                options: ["None", "Vegetarian", "Vegan", "Keto", "Paleo", "Gluten-Free", "Pescatarian"],
                selectedOptions: $viewModel.data.dietaryPreferences,
                onNext: viewModel.next
            )
            
        case .commitmentChart:
            CommitmentChartView(viewModel: viewModel)
            
        case .timeStats:
            TimeStatsView(viewModel: viewModel)
            
        case .cookingPersona:
            PersonaView(viewModel: viewModel)
            
        case .personalizedValueProp:
            let isExploratory = viewModel.data.cookingPersona == .exploratory
            let title = isExploratory ? "Perfect for Explorers!" : "Perfect for Planners!"
            let text = isExploratory 
                ? "Recipe Ready helps you by collating all your fun exploratory recipes. Experiment with existing ingredients!" 
                : "Recipe Ready collates all your preferences in one place so you always have a list of safe recipes to pick from."
            
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: isExploratory ? "sparkles.rectangle.stack.fill" : "doc.text.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.primaryGreen)
                
                Text(title)
                    .font(.heading1)
                    .multilineTextAlignment(.center)
                
                Text(text)
                    .font(.bodyRegular)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                OnboardingButton(title: "Let's set it up", action: viewModel.next)
            }
            .padding()
            
        case .trustAndPrivacy:
            TrustAndPrivacyView(viewModel: viewModel)
            
            
        case .reassurance:
             VStack(spacing: 24) {
                 // Title
                 Text("That's Alright!")
                     .font(.display)
                     .foregroundColor(.textPrimary)
                     .padding(.top, 20)
                 
                 // Social Proof / Stat
                 Text("94% of home cooks say Recipe Ready helps them finally cook the recipes they’ve been saving for later.")
                     .font(.bodyRegular)
                     .foregroundColor(.textSecondary)
                     .multilineTextAlignment(.center)
                     .padding(.horizontal, 32)
                 
                 Spacer()
                 
                 // Hero Graphic: Saved -> Cooked
                 HStack(spacing: 20) {
                     // Saved State
                     Image(systemName: "bookmark.fill")
                         .font(.system(size: 50))
                         .foregroundColor(.gray)
                     
                     // Transition
                     Image(systemName: "arrow.right")
                         .font(.system(size: 30, weight: .bold))
                         .foregroundColor(.gray.opacity(0.5))
                     
                     // Cooked State
                     Image(systemName: "frying.pan.fill")
                         .font(.system(size: 60))
                         .foregroundColor(.primaryGreen)
                 }
                 .padding(20)
                 
                 Spacer()
                 
                 // Supportive Text
                 Text("We're here to help you\nconquer your kitchen 🤝")
                     .font(.heading2)
                     .foregroundColor(.textPrimary)
                     .multilineTextAlignment(.center)
                     .padding(.bottom, 20)
                 
                 // Button
                 OnboardingButton(title: "Continue", action: viewModel.next)
             }
             .padding(.bottom, 20)
             
        case .socialMediaSupport:
             VStack(spacing: 24) {
                 // Title
                 Text("Awesome 🥳")
                     .font(.display)
                     .multilineTextAlignment(.center)
                     .padding(.top, 40)
                 
                 Spacer()
                 
                 // Logos Side-by-Side
                 HStack(spacing: 40) {
                     VStack(spacing: 12) {
                         Image("instagram")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 80, height: 80)
                         
                         Text("Instagram")
                             .font(.heading3)
                             .foregroundColor(.textPrimary)
                     }
                     
                     VStack(spacing: 12) {
                         Image("tiktok")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 80, height: 80)
                         
                         Text("TikTok")
                             .font(.heading3)
                             .foregroundColor(.textPrimary)
                     }
                 }
                 .padding(.horizontal, 24)
                 
                 Spacer()
                 
                 // Description Text
                 Text("We support extracting recipes from your favourite food platforms like Instagram and TikTok.")
                     .font(.bodyRegular)
                     .multilineTextAlignment(.center)
                     .padding(.horizontal, 32)
                     .padding(.bottom, 16)
                 
                 // Button
                 OnboardingButton(title: "Great!", action: viewModel.next)
             }
             .padding(.bottom, 20)
            
        case .setupLoading:
            SetupLoadingView(viewModel: viewModel)
            
        case .freeGift:
            FreeGiftView(viewModel: viewModel)
            
        case .cookbookIntro:
            CookbookIntroView(viewModel: viewModel)
            
        case .trialInfo:
            TrialInfoView(viewModel: viewModel)
            
        case .notificationPermission:
             VStack(spacing: 24) {
                 Spacer()
                 Image(systemName: "bell.badge.circle.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(.primaryBlue)
                 Text("Don't miss a thing")
                     .font(.heading1)
                 Text("Tap Allow to get your trial reminder and recipe updates.")
                     .font(.bodyRegular)
                     .multilineTextAlignment(.center)
                     .padding(.horizontal)
                 Spacer()
                 OnboardingButton(title: "Enable Notifications") {
                     UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                     viewModel.next()
                 }
             }
            
        case .paywall:
            RevenueCatPaywallView(viewModel: viewModel)
        }
    }
}

// Helper to make enum printable for debug
extension OnboardingStep: CustomStringConvertible {
    var description: String {
        switch self {
        case .welcome: return "Welcome"
        case .featuresOverview: return "Features"
        case .gender: return "Gender"
        case .acquisitionSource: return "Source"
        case .competitorUsage: return "Competitor"
        case .commitmentChart: return "Commitment"
        case .cookingFrequency: return "Frequency"
        case .decisionStruggle: return "Decision Struggle"
        case .timeStats: return "Time Stats"
        case .goals: return "Goals"
        case .obstacles: return "Obstacles"
        case .reassurance: return "Reassurance"
        case .recipeSources: return "Recipe Sources"
        case .socialMediaSupport: return "Social Media"
        case .dietaryPreferences: return "Dietary"
        case .cookingPersona: return "Persona"
        case .personalizedValueProp: return "Value Prop"
        case .trustAndPrivacy: return "Trust & Privacy"
        case .setupLoading: return "Loading"
        case .freeGift: return "Free Gift"
        case .cookbookIntro: return "Cookbook Intro"
        case .trialInfo: return "Trial Info"
        case .notificationPermission: return "Notifications"
        case .paywall: return "Paywall"
        }
    }
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView()
    }
}
