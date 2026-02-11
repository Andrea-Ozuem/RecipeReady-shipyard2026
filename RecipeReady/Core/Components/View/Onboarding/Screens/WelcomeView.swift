import SwiftUI
import AVKit

struct WelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    // We hold the player in a State object so it persists across refreshes
    @State private var player: AVPlayer?
    
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
                if let player = player {
                    VideoPlayer(player: player)
                        .disabled(true) // Disable controls
                        .onAppear {
                            player.play()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(4) // Bezel space
                } else {
                    // Fallback / Loading state
                    ZStack {
                        Color.gray.opacity(0.1)
                        if player == nil {
                             // Only show if we truly failed to load or are initializing
                            Text("Loading Video...")
                                .foregroundColor(.gray)
                        }
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
        .onAppear {
            setupPlayer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { notification in
            // Loop the video
            if let item = notification.object as? AVPlayerItem, item == player?.currentItem {
                player?.seek(to: .zero)
                player?.play()
            }
        }
    }
    
    private func setupPlayer() {
        // Look for the file in the main bundle
        guard let url = Bundle.main.url(forResource: "demo", withExtension: "mp4") else {
            print("❌ Error: Could not find demo.mp4 in bundle.")
            return
        }
        
        // Create player only if not already created to avoid resets
        if player == nil {
            let p = AVPlayer(url: url)
            p.isMuted = true // Often better for onboarding videos to be muted by default
            self.player = p
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(viewModel: OnboardingViewModel())
    }
}
