import SwiftUI
import AVKit

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    // Placeholder video URL - in a real app, integrate a local file or remote URL
    private let videoURL = URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // iPhone Mockup Video Container
            ZStack {
                // Device Frame/Border
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.black)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                // Video Content
                if let url = videoURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .disabled(true)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(4) // Bezel space
                } else {
                    ZStack {
                        Color.gray.opacity(0.1)
                        Text("Demo Video")
                            .foregroundColor(.gray)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .padding(4)
                }
                
                // Notch Indication (Optional decorative touch)
                VStack {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 100, height: 24)
                        .padding(.top, 12)
                    Spacer()
                }
            }
            .aspectRatio(9/19.5, contentMode: .fit) // Typical iPhone aspect ratio
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            
            // Text Content
            VStack(spacing: 12) {
                Text("Recipe tracking made easy")
                    .font(.display) // Larger, bolder font
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textPrimary)
                
                Text("Go from inspired to ready meal.")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            
            // Action Button
            OnboardingButton(title: "Get Started") {
                viewModel.next()
            }
            .padding(.top, 0)
        }
        .edgesIgnoringSafeArea(.top) // Allow phone mockup to feel expansive if needed
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: OnboardingViewModel())
    }
}
