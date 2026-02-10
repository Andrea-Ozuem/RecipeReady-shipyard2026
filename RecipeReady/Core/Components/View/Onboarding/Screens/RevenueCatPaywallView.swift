import SwiftUI
import RevenueCat
import RevenueCatUI

struct RevenueCatPaywallView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var revenueCatService: RevenueCatService
    
    var body: some View {
        ZStack {
            if let offering = revenueCatService.currentOffering {
                RevenueCatUI.PaywallView(offering: offering)
                    .onRestoreCompleted { customerInfo in
                        // Handle successful restore
                        if customerInfo.entitlements["Recipe Ready Pro"]?.isActive == true {
                            viewModel.completeOnboarding()
                        }
                    }
                    .onPurchaseCompleted { customerInfo in
                        // Handle successful purchase
                        viewModel.completeOnboarding()
                    }
                    .onPurchaseFailure { error in
                        // Error is already handled by RevenueCat UI
                        print("Purchase failed: \(error.localizedDescription)")
                    }
            } else {
                // Loading state while offerings are being fetched
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Loading subscription options...")
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .onAppear {
            // Ensure offerings are fetched
            revenueCatService.fetchOfferings()
        }
    }
}

struct RevenueCatPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        RevenueCatPaywallView(viewModel: OnboardingViewModel())
            .environmentObject(RevenueCatService.shared)
    }
}
