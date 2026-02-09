//
//  ProfileView.swift
//  RecipeReady
//
//  Created by RecipeReady Team on 09/02/2026.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var revenueCatService: RevenueCatService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    ProfileHeaderView(onEditProfile: {
                        // TODO: Implement Edit Profile Flow
                    })
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.divider)
                        .padding(.horizontal)

                    
                    // System Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("System")
                            .font(.heading2)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Measurement System Toggle
                            ProfileOptionRow(
                                icon: viewModel.measurementSystem.icon,
                                title: "Measurement System"
                            ) {
                                Menu {
                                    Picker("Measurement System", selection: $viewModel.measurementSystem) {
                                        ForEach(MeasurementSystem.allCases) { system in
                                            Text(system.rawValue).tag(system)
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(viewModel.measurementSystem.rawValue)
                                            .font(.bodyRegular)
                                            .foregroundColor(.textSecondary)
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.captionMeta)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            ProfileOptionRow(icon: "bell", title: "Notifications", text: "On")
                                .padding(.horizontal)
                        }
                    }
                    
                    
                    Divider()
                        .background(Color.divider)
                        .padding(.horizontal)
                    
                    // Support Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Support")
                            .font(.heading2)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ProfileOptionRow(icon: "bubble.left.and.bubble.right", title: "Feedback", action: viewModel.contactSupport)
                                .padding(.horizontal)
                                
                            Divider().padding(.leading)
                            
                            ProfileOptionRow(icon: "ant", title: "Report a bug", action: viewModel.contactSupport)
                                .padding(.horizontal)
                            
                            Divider().padding(.leading)
                            
                            ProfileOptionRow(icon: "star", title: "Rate App", showChevron: false, action: viewModel.rateApp)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Version Info
                    Text("Version \(viewModel.appVersion) (\(viewModel.buildNumber))")
                        .font(.captionMeta)
                        .foregroundColor(.textSecondary.opacity(0.6))
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
                .padding(.top)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.screenBackground) 
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(RevenueCatService.shared)
}
