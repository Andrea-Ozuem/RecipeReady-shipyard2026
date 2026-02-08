import SwiftUI

struct OnboardingProgressBar: View {
    var progress: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                // Active Progress
                Capsule()
                    .fill(Color.primaryGreen) // Using Design System color
                    .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 6)
    }
}

struct OnboardingProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OnboardingProgressBar(progress: 0.2)
            OnboardingProgressBar(progress: 0.5)
            OnboardingProgressBar(progress: 0.8)
        }
        .padding()
    }
}
