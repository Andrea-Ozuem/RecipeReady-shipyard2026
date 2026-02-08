import SwiftUI

struct PaywallView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header Image or Icon
                    VStack(spacing: 16) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .padding(.top, 40)
                        
                        Text("Unlock Recipe Ready Premium")
                            .font(.heading1)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Features
                    VStack(spacing: 20) {
                        FeatureRow(icon: "wand.and.stars", text: "Unlimited AI Recipe Extraction")
                        FeatureRow(icon: "folder.fill", text: "Unlimited Cookbooks")
                        FeatureRow(icon: "list.bullet.rectangle.portrait.fill", text: "Smart Grocery Lists")
                        FeatureRow(icon: "chart.bar.fill", text: "Personalized Cooking Stats")
                        FeatureRow(icon: "gift.fill", text: "Bonus: Free Premium Cookbook")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Pricing
                    VStack(spacing: 12) {
                        Text("7 Days Free, then $4.99/month")
                            .font(.heading3)
                            .foregroundColor(.primaryBlue)
                        
                        Text("Auto-renewable. Cancel anytime.")
                            .font(.captionMeta)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            
            // Fixed Bottom
            VStack(spacing: 16) {
                OnboardingButton(title: "Start Free Trial") {
                    viewModel.completeOnboarding()
                }
                .padding(.bottom, 0) // Remove default bottom padding from button component
                
                Button("Restore Purchases") {
                    // Restore logic
                }
                .font(.captionMeta)
                .foregroundColor(.textSecondary)
            }
            .padding()
            .background(Color.white.shadow(radius: 5))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primaryGreen)
                .frame(width: 30)
            
            Text(text)
                .font(.bodyRegular)
            
            Spacer()
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(viewModel: OnboardingViewModel())
    }
}
