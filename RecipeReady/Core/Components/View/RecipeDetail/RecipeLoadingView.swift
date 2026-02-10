//
//  RecipeLoadingView.swift
//  RecipeReady
//
//  Reusable loading view with circular progress ring and dynamic status text.
//

import SwiftUI
import Combine

struct RecipeLoadingView: View {
    @State private var currentMessageIndex = 0
    @State private var progress: CGFloat = 0.0
    @State private var rotationAngle: Double = 0.0

    // Status messages aligned with extraction pipeline
    private let statusMessages = [
        "Analyzing caption...",
        "Extracting audio...",
        "Parsing ingredients...",
        "Creating your recipe..."
    ]

    // Timer to cycle through messages every 3 seconds
    private let messageTimer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()

    // Timer for progress animation (simulated indeterminate progress)
    private let progressTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Circular progress ring with fork.knife icon
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 20)

                // Progress circle (indeterminate animation)
                Circle()
                    .trim(from: 0, to: 0.25) // Show 25% of circle
                    .stroke(
                        Color.primaryGreen,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: rotationAngle)

                // Fork and knife icon in center
                Image(systemName: "fork.knife")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.primaryGreen)
                    .rotationEffect(.degrees(rotationAngle * 0.1)) // Gentle rotation
                    .animation(.linear(duration: 15).repeatForever(autoreverses: false), value: rotationAngle)
            }
            .frame(width: 200, height: 200)
            .onAppear {
                rotationAngle = 360
            }

            // Dynamic status text with smooth transitions
            Text(currentMessage)
                .font(.bodyRegular)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .transition(.opacity)
                .id(currentMessage) // Force view refresh for smooth transition

            Spacer()
        }
        .padding()
        .onReceive(messageTimer) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentMessageIndex = (currentMessageIndex + 1) % statusMessages.count
            }
        }
    }

    private var currentMessage: String {
        statusMessages[currentMessageIndex]
    }
}

// MARK: - Preview

#Preview {
    RecipeLoadingView()
}

