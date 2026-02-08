import SwiftUI

struct OnboardingHeader: View {
    var progress: Double
    var onBack: () -> Void
    var showBack: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            if showBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
            }
            
            OnboardingProgressBar(progress: progress)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .frame(height: 44)
        .background(Color.screenBackground)
    }
}

struct OnboardingHeader_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingHeader(progress: 0.4, onBack: {}, showBack: true)
            .previewLayout(.sizeThatFits)
    }
}
