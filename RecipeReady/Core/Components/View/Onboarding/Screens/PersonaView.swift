import SwiftUI

struct PersonaView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("How do you like to cook?")
                .font(.heading1)
            
            VStack(spacing: 16) {
                // Card 1: Exploratory
                Button(action: {
                    viewModel.setPersona(.exploratory)
                }) {
                    PersonaCard(
                        title: "I'm Exploratory",
                        description: "I love trying fun, new recipes and experimenting with ingredients."
                    )
                }
                
                // Card 2: Strict
                Button(action: {
                    viewModel.setPersona(.strict)
                }) {
                    PersonaCard(
                        title: "I have my Preferences",
                        description: "I stick to what I know and have specific requirements."
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }
        }
    }
}

struct PersonaCard: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.heading2)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 8)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PersonaView_Previews: PreviewProvider {
    static var previews: some View {
        PersonaView(viewModel: OnboardingViewModel())
            .background(Color.secondary.opacity(0.1))
    }
}
