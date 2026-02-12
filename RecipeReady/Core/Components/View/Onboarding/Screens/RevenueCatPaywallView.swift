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
            } else if let errorMessage = revenueCatService.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Configuration Error")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button(action: {
                        revenueCatService.errorMessage = nil
                        revenueCatService.fetchOfferings()
                    }) {
                        Text("Retry")
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                // Loading state while offerings are being fetched
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Loading subscription options...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
