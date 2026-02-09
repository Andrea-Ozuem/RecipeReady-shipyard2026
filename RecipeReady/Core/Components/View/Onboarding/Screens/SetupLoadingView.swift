import SwiftUI
import Combine

struct SetupLoadingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var progress: CGFloat = 0.0
    
    // Timer to simulate loading
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.primaryGreen,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.display)
                    .foregroundColor(.primaryGreen)
                
                if progress >= 1.0 {
                    MinimalConfettiView()
                }
            }
            .frame(width: 200, height: 200)
            
            VStack(spacing: 12) {
                Text("Setting up your profile...")
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                
                Text(loadingText)
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .transition(.opacity)
                    .id(loadingText) // Force redraw for transition
            }
            
            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            if progress < 1.0 {
                progress += 0.01
                
                // Haptic feedback at intervals
                if Int(progress * 100) % 20 == 0 {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }
            } else {
                timer.upstream.connect().cancel()
                // Auto advance after completion
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    viewModel.next()
                }
            }
        }
    }
    
    var loadingText: String {
        if progress < 0.3 { return "Analyzing preferences..." }
        else if progress < 0.6 { return "Curating recipes..." }
        else if progress < 0.9 { return "Finalizing your plan..." }
        else { return "All set!" }
    }
}

struct SetupLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        SetupLoadingView(viewModel: OnboardingViewModel())
    }
}

struct MinimalConfettiView: View {
    @State private var animate = false
    
    let colors: [Color] = [.primaryGreen, .primaryBlue]
    
    var body: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(colors[i % 2])
                    .frame(width: 8, height: 8)
                    .modifier(ConfettiModifier(animate: animate, index: i))
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiModifier: ViewModifier {
    let animate: Bool
    let index: Int
    
    // Deterministic random animation values based on index
    var xOffset: CGFloat {
        let angle = Double(index) * 12.0 // Spread radially
        return CGFloat(cos(angle * .pi / 180) * 150)
    }
    
    var yOffset: CGFloat {
        // Explode upwards then fall
        return animate ? 200 : -200 
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: animate ? xOffset + CGFloat.random(in: -20...20) : 0, 
                    y: animate ? CGFloat.random(in: -300...300) : 0)
            .opacity(animate ? 0 : 1)
            .animation(Animation.easeOut(duration: 2.5).delay(Double(index) * 0.02), value: animate)
    }
}
