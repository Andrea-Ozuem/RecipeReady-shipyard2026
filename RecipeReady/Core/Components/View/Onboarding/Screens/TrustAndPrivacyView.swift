import SwiftUI

struct TrustAndPrivacyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration (Hands High-fiving/Clapping)
            // Using a system placeholder or custom circle for now to match the Cal AI style
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryGreen.opacity(0.1), Color.blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Image(systemName: "hand.thumbsup.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.primaryBlue)
            }
            .padding(.bottom, 20)
            
            // Title & Subtitle
            VStack(spacing: 12) {
                Text("Thank you for\ntrusting us")
                    .font(.display) // Large title
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textPrimary)
                
                Text("Now let's personalize Recipe Ready for you...")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Privacy Assurance
            ZStack(alignment: .top) {
                // Card Background & Content
                VStack(spacing: 8) {
                    Text("Your privacy and security matter to us.")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("We promise to always keep your\npersonal information private and secure.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 36) // Extra top padding for the lock
                .padding(.bottom, 24)
                .padding(.horizontal, 24)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
                .padding(.top, 24) // Push the card down to make room for the lock to pop out
                
                // Lock Icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(12)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            // Continue Button
            OnboardingButton(title: "Continue", action: viewModel.next)
        }
        .padding(.top, 20)
    }
}

struct TrustAndPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        TrustAndPrivacyView(viewModel: OnboardingViewModel())
    }
}
