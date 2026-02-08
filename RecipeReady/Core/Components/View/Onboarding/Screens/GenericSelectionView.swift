import SwiftUI

struct GenericSelectionView: View {
    let title: String
    let subtitle: String?
    let options: [String]
    @Binding var selectedOption: String?
    let onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer() // Vertically center the content
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32) // Extra spacing between header and options
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        OnboardingOptionRow(
                            title: option,
                            isSelected: selectedOption == option,
                            action: {
                                selectedOption = option
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            Spacer()
            
            OnboardingButton(
                title: "Continue",
                action: onNext,
                isEnabled: selectedOption != nil
            )
        }
    }
}

// Separate view for Multi-Selection to keep logic clean
struct GenericMultiSelectionView: View {
    let title: String
    let subtitle: String?
    let options: [String]
    @Binding var selectedOptions: Set<String>
    let onNext: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer() // Vertically center the content
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.heading1)
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32) // Extra spacing between header and options
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        OnboardingOptionRow(
                            title: option,
                            isSelected: selectedOptions.contains(option),
                            action: {
                                if selectedOptions.contains(option) {
                                    selectedOptions.remove(option)
                                } else {
                                    selectedOptions.insert(option)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            Spacer()
            
            OnboardingButton(
                title: "Continue",
                action: onNext,
                isEnabled: !selectedOptions.isEmpty
            )
        }
    }
}
