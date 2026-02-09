import SwiftUI

struct FreeGiftView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Gift Icon/Image
            ZStack {
                Circle()
                    .fill(Color.softBeige)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.primaryBlue)
            }
            .padding(.bottom, 20)
            
            Text("We have a free gift for you!")
                .font(.heading1)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("You get a premium cookbook for free!")
                    .font(.heading3)
                    .foregroundColor(.textPrimary)
                
                Text("Valued at $30. Yours to keep forever.")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            OnboardingButton(title: "Claim Gift") {
                viewModel.next()
            }
        }
        .padding()
    }
}

struct FreeGiftView_Previews: PreviewProvider {
    static var previews: some View {
        FreeGiftView(viewModel: OnboardingViewModel())
    }
}
