import SwiftUI

struct OnboardingOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodyRegular)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .multilineTextAlignment(.leading)
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.primaryGreen : Color.gray.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                        // Optional: Keep border for unselected if it helps contrast
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingOptionRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OnboardingOptionRow(title: "Option A", isSelected: true, action: {})
            OnboardingOptionRow(title: "Option B", isSelected: false, action: {})
        }
        .padding()
    }
}
