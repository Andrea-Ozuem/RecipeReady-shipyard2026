import SwiftUI

struct FeaturesOverviewView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("square.and.arrow.down", "Extract from Social Media", "Turn TikTok & Instagram videos into recipes"),
        ("text.line.first.and.arrowtriangle.forward", "Step-by-Step Cooking Mode", "Hands-free, swipeable instructions"),
        ("cart.fill", "Smart Grocery List", "Auto-generate shopping lists from recipes"),
        ("books.vertical.fill", "Organize into Cookbooks", "Build your personal recipe collection"),
        ("slider.horizontal.3", "Adjust Servings", "Scale ingredient quantities up or down"),
        ("bell.badge", "Set Cooking Reminders", "Never forget to cook your favourite meals")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Here's what you get ✨")
                .font(.display)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        let color: Color = index.isMultiple(of: 2) ? .primaryGreen : .primaryBlue
                        featureRow(
                            icon: feature.icon,
                            color: color,
                            title: feature.title,
                            subtitle: feature.subtitle
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            
            OnboardingButton(title: "Continue") {
                viewModel.next()
            }
        }
        .padding(.bottom, 20)
    }
    
    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.heading3)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.captionMeta)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct FeaturesOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesOverviewView(viewModel: OnboardingViewModel())
    }
}
