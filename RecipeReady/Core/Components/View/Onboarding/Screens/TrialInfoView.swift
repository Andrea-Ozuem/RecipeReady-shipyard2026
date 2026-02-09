import SwiftUI

struct TrialInfoView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.primaryGreen)
            
            VStack(spacing: 16) {
                Text("Try 7 days for free")
                    .font(.heading1)
                
                Text("Everyone deserves a better cooking experience.")
                    .font(.bodyRegular)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .font(.iconRegular)
                        .foregroundColor(.primaryBlue)
                    Text("We'll remind you 2 days before trial ends")
                        .font(.bodyBold)
                }
                
                HStack {
                    Image(systemName: "lock.open.fill")
                        .font(.iconRegular)
                        .foregroundColor(.primaryBlue)
                    Text("No commitment. Cancel anytime.")
                        .font(.bodyBold)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
            
            Spacer()
            
            OnboardingButton(title: "Enable Reminders & Continue") {
                requestNotificationPermission()
                viewModel.next()
            }
        }
        .padding()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // Handle result if needed, but for onboarding speed we usually just move on or rely on system prompt
        }
    }
}

import UserNotifications

struct TrialInfoView_Previews: PreviewProvider {
    static var previews: some View {
        TrialInfoView(viewModel: OnboardingViewModel())
    }
}
