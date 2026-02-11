//
//  EditProfileView.swift
//  RecipeReady
//
//  Created by RecipeReady Team on 11/02/2026.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var tempName: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Info")) {
                    HStack {
                        Text("Name")
                        TextField("Display Name", text: $tempName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text(String(tempName.prefix(1)).uppercased())
                                .font(.system(size: 60, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 120, height: 120)
                                .background(Color.primaryGreen)
                                .clipShape(Circle())
                            
                            Text("Avatar updates automatically")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                tempName = viewModel.userName
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateName(tempName)
                        dismiss()
                    }
                    .disabled(tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditProfileView(viewModel: ProfileViewModel())
}
