import SwiftUI

struct OnboardingButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.bodyBold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.primaryGreen : Color.gray.opacity(0.4))
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct OnboardingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OnboardingButton(title: "Continue", action: {})
            OnboardingButton(title: "Disabled", action: {}, isEnabled: false)
        }
    }
}
