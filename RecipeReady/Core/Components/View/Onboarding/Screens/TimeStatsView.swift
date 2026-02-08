import SwiftUI

struct TimeStatsView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var animateChart = false
    
    // Logic to calculate hours based on selection
    var calculatedHours: Double {
        let answer = viewModel.data.decisionStruggleDuration ?? "15-30"
        let minutes: Double
        
        if answer.contains("Less") { minutes = 5 }
        else if answer.contains("30") { minutes = 30 }
        else if answer.contains("15") { minutes = 15 }
        else { minutes = 20 }
        
        return (minutes * 7) / 60
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 8) {
                Text("Reclaim your time")
                    .font(.display)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("You spend ~\(String(format: "%.1f", calculatedHours)) hours a week deciding what to cook.")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Chart Visualization
            HStack(alignment: .bottom, spacing: 40) {
                // Bar 1: Current Time (Gray)
                VStack(spacing: 8) {
                    Text("Average")
                        .font(.captionMeta)
                        .foregroundColor(.textSecondary)
                        .textCase(.uppercase)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 200) // Fixed height reference
                    
                    Text("\(String(format: "%.1f", calculatedHours)) hrs")
                        .font(.bodyBold)
                        .foregroundColor(.textSecondary)
                }
                
                // Bar 2: Recipe Ready (Green)
                VStack(spacing: 8) {
                    Text("with Recipe Ready")
                        .font(.captionMeta)
                        .foregroundColor(.primaryGreen)
                        .textCase(.uppercase)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primaryGreen)
                        .frame(width: 60, height: animateChart ? 100 : 0) // Half height animation
                    
                    if animateChart {
                        Text("~1 hr") // Estimate based on efficiency
                            .font(.bodyBold)
                            .foregroundColor(.primaryGreen)
                            .transition(.scale)
                    }
                }
            }
            .frame(height: 260)
            .padding(.vertical, 20)
            
            Spacer()
            
            // Social Proof & Value Prop (No Cards)
            VStack(spacing: 12) {
                Text("You're not alone —\n70% of home cooks face this struggle.")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Cut that time in half!")
                    .font(.heading3)
                    .foregroundColor(.textPrimary)
            }
            .padding(.bottom, 20)
            
            // Button
            OnboardingButton(title: "I want to save time") {
                viewModel.next()
            }
        }
        .padding(.bottom, 20)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.2)) {
                animateChart = true
            }
        }
    }
}

struct TimeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        TimeStatsView(viewModel: OnboardingViewModel())
    }
}
