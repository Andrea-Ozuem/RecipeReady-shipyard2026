//
//  ProfileOptionRow.swift
//  RecipeReady
//
//  Created by RecipeReady Team on 09/02/2026.
//

import SwiftUI

struct ProfileOptionRow<TrailingContent: View>: View {
    let icon: String // SF Symbol name
    let title: String
    let trailingContent: TrailingContent
    var action: (() -> Void)? = nil
    
    init(icon: String, title: String, action: (() -> Void)? = nil, @ViewBuilder trailingContent: () -> TrailingContent) {
        self.icon = icon
        self.title = title
        self.action = action
        self.trailingContent = trailingContent()
    }
    
    // Convenience init for just a chevron or text
    init(icon: String, title: String, text: String? = nil, showChevron: Bool = false, action: (() -> Void)? = nil) where TrailingContent == AnyView {
        self.icon = icon
        self.title = title
        self.action = action
        self.trailingContent = AnyView(
            HStack(spacing: 8) {
                if let text = text {
                    Text(text)
                        .font(.bodyRegular)
                        .foregroundColor(.textSecondary)
                }
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.iconSmall)
                        .foregroundColor(.textSecondary)
                }
            }
        )
    }

    var body: some View {
        if let action = action {
            Button(action: action) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }
    
    private var rowContent: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.iconRegular)
                .foregroundColor(.textPrimary)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.bodyRegular)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            trailingContent
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle()) // Make full row tappable
    }
}

#Preview {
    VStack {
        ProfileOptionRow(icon: "globe", title: "Languages", text: "English")
        ProfileOptionRow(icon: "bell", title: "Notifications")
        ProfileOptionRow(icon: "star", title: "Rate App", showChevron: false)
    }
    .padding()
}
