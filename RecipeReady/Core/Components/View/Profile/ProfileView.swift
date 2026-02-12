//
//  ProfileView.swift
//  RecipeReady
//
//  Created by RecipeReady Team on 09/02/2026.
//

import SwiftUI
import RevenueCat

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var revenueCatService: RevenueCatService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    ProfileHeaderView(viewModel: viewModel)
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.divider)
                    .padding(.horizontal)
                    
                    // Account Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Account")
                            .font(.heading2)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 20) {
                            // Plan Status Row
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Plan")
                                        .font(.bodyRegular)
                                        .foregroundColor(.textPrimary)
                                    
                                    if let info = revenueCatService.customerInfo, let date = info.latestExpirationDate {
                                        Text("Renews \(date.formatted(date: .long, time: .omitted))")
                                            .font(.captionMeta)
                                            .foregroundColor(.textSecondary)
                                    } else {
                                         Text("Renews --") // Placeholder
                                            .font(.captionMeta)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    // Logic for trial status could be complex, simplifying for MVP
                                    if revenueCatService.customerInfo?.entitlements["Recipe Ready Pro"]?.periodType == .trial {
                                        Text("Free Trial")
                                            .font(.bodyRegular)
                                            .foregroundColor(.textPrimary)
                                    }
                                }
                            }
                            
                            // Manage Subscription Button
                            Button(action: {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Manage subscription")
                                    .font(.bodyBold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 32)
                                    .background(Color.primaryBlue) // Using primaryBlue as per previous, or primaryGreen? Design looks dark.
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                    
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
                                icon: "ruler",
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
                                            .font(.iconSmall)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            ProfileOptionRow(
                                icon: "bell",
                                title: "Notifications"
                            ) {
                                Toggle("", isOn: $viewModel.areNotificationsEnabled)
                                    .labelsHidden()
                                    .tint(Color.primaryGreen)
                            }
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

                            ProfileOptionRow(icon: "ant", title: "Report a bug", action: viewModel.contactSupport)
                                .padding(.horizontal)

                            ProfileOptionRow(icon: "star", title: "Rate App", showChevron: false, action: viewModel.rateApp)
                                .padding(.horizontal)

                            ProfileOptionRow(icon: "hand.raised", title: "Privacy Policy", showChevron: true, action: viewModel.openPrivacyPolicy)
                                .padding(.horizontal)

                            ProfileOptionRow(icon: "doc.text", title: "Terms of Use", showChevron: true, action: viewModel.openTermsOfUse)
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
            .sheet(item: $viewModel.activeSheet) { sheet in
                switch sheet {
                case .editProfile:
                    EditProfileView(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(RevenueCatService.shared)
}
