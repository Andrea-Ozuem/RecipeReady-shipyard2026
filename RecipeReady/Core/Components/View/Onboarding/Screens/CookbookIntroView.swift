import SwiftUI

struct CookbookIntroView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 8) {
                Text("Introducing")
                    .font(.heading3)
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)
                    .tracking(2) // Letter spacing
                
                Text("Eitan Eats the World")
                    .font(.display)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textPrimary)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Image
            Image("EitanCookbook") // Using the asset name we found
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
            
            Spacer()
            
            // Description
            VStack(spacing: 12) {
                Text("New Comfort Classics to Cook Right Now")
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 8)
                
                Text("85 fresh comfort food recipes highlighting the enthusiasm, creativity, and foolproof techniques of the TikTok cooking prodigy.")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 20)
            
            // Button
            OnboardingButton(title: "Check it out", action: viewModel.next)
        }
        .padding(.bottom, 20)
    }
}

struct CookbookIntroView_Previews: PreviewProvider {
    static var previews: some View {
        CookbookIntroView(viewModel: OnboardingViewModel())
    }
}
