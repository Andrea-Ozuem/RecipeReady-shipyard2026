import SwiftUI

struct CommitmentChartView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var animateChart = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Recipe Ready is committed to improving your kitchen experience")
                    .font(.heading1)
                    .multilineTextAlignment(.center)
                
                Text("See how we improve meal satisfaction")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.top)

            
            Spacer()
            
            // Chart
            HStack(alignment: .bottom, spacing: 40) {
                // Bar 1: Current
                VStack {
                    Text("30%")
                        .font(.bodyBold)
                        .foregroundColor(.textSecondary)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 120)
                    
                    Text("Before")
                        .font(.captionMeta)
                        .foregroundColor(.textSecondary)
                }
                
                // Bar 2: RecipeReady
                VStack {
                    if animateChart {
                        Text("95%")
                            .font(.bodyBold)
                            .foregroundColor(.primaryGreen)
                            .transition(.scale)
                    }
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primaryGreen)
                        .frame(width: 60, height: animateChart ? 280 : 0) // Animate height
                    
                    Text("With App")
                        .font(.captionMeta)
                        .foregroundColor(.primaryGreen)
                }
            }
            .frame(height: 320)
            
            Spacer()
            
            OnboardingButton(title: "Continue") {
                viewModel.next()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0).delay(0.3)) {
                animateChart = true
            }
        }
    }
}

struct CommitmentChartView_Previews: PreviewProvider {
    static var previews: some View {
        CommitmentChartView(viewModel: OnboardingViewModel())
    }
}
