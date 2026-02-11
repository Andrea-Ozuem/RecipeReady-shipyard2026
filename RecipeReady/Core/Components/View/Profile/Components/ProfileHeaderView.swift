//
//  ProfileHeaderView.swift
//  RecipeReady
//
//  Created by RecipeReady Team on 09/02/2026.
//

import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            // Avatar Circle
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.2)) // Light background
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGreen, lineWidth: 2)
                    )
                
                Text(viewModel.userInitial)
                    .font(.display) // 32pt bold
                    .foregroundColor(.primaryGreen)
            }
            .frame(width: 80, height: 80)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.userName)
                        .font(.heading2) // 20pt bold
                        .foregroundColor(.textPrimary)
                }
                
                Button(action: {
                    viewModel.activeSheet = .editProfile
                }) {
                    Text("Edit profile")
                        .font(.captionMeta)
                        .foregroundColor(.primaryGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.primaryGreen, lineWidth: 1)
                        )
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    ProfileHeaderView(viewModel: ProfileViewModel())
        .padding()
}
