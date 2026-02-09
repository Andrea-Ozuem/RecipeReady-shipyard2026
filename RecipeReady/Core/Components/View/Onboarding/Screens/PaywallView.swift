import SwiftUI
import RevenueCat

struct PaywallView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @EnvironmentObject var revenueCatService: RevenueCatService
    
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header Image or Icon
                    VStack(spacing: 16) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.yellow)
                            .padding(.top, 40)
                        
                        Text("Unlock Recipe Ready Premium")
                            .font(.heading1)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let currentOffering = revenueCatService.currentOffering {
                        // Features
                        VStack(spacing: 20) {
                            FeatureRow(icon: "wand.and.stars", text: "Unlimited AI Recipe Extraction")
                            FeatureRow(icon: "folder.fill", text: "Unlimited Cookbooks")
                            FeatureRow(icon: "list.bullet.rectangle.portrait.fill", text: "Smart Grocery Lists")
                            FeatureRow(icon: "chart.bar.fill", text: "Personalized Cooking Stats")
                            FeatureRow(icon: "gift.fill", text: "Bonus: Free Premium Cookbook")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Pricing Options
                        VStack(spacing: 16) {
                            if let annual = currentOffering.annual {
                                PackageOptionView(
                                    package: annual,
                                    isSelected: selectedPackage == annual || selectedPackage == nil, // Default to annual
                                    action: { selectedPackage = annual }
                                )
                            }
                            
                            if let monthly = currentOffering.monthly {
                                PackageOptionView(
                                    package: monthly,
                                    isSelected: selectedPackage == monthly,
                                    action: { selectedPackage = monthly }
                                )
                            }
                            
                            // Retention Offer
                            if let retentionOffering = revenueCatService.retentionOffering, 
                               let retentionPackage = retentionOffering.availablePackages.first {
                                
                                Button(action: { selectedPackage = retentionPackage }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Special Offer")
                                                .font(.bodyBold)
                                                .foregroundColor(.white)
                                            
                                            Text("3 Days Free, then \(retentionPackage.storeProduct.localizedPriceString)/year")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedPackage == retentionPackage {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.iconRegular)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.white.opacity(0.7))
                                                .font(.iconRegular)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.primaryGreen) // Highlight this offer
                                            .shadow(color: Color.primaryGreen.opacity(0.3), radius: 5, x: 0, y: 3)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white, lineWidth: selectedPackage == retentionPackage ? 2 : 0)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .onAppear {
                            // Set default selection to annual if available
                            if selectedPackage == nil {
                                selectedPackage = currentOffering.annual
                            }
                        }

                    } else {
                        ProgressView("Loading products...")
                            .padding()
                    }
                }
            }
            
            // Fixed Bottom
            VStack(spacing: 16) {
                if let _ = revenueCatService.currentOffering {
                    OnboardingButton(title: buttonTitle, action: purchaseSelectedPackage)
                        .disabled(selectedPackage == nil || isPurchasing)
                        .opacity(isPurchasing ? 0.6 : 1)
                        .overlay {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                }
                
                Button("Restore Purchases") {
                    restorePurchases()
                }
                .font(.captionMeta)
                .foregroundColor(.textSecondary)
                .disabled(isPurchasing)
            }
            .padding()
            .background(Color.white.shadow(radius: 5))
        }
        .edgesIgnoringSafeArea(.bottom)
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            revenueCatService.fetchOfferings()
        }
    }
    
    // Computed property for dynamic button title
    var buttonTitle: String {
        if let package = selectedPackage {
            if package.packageType == .annual {
                 return "Start Free Trial"
            } else {
                return "Subscribe for \(package.storeProduct.localizedPriceString)/mo"
            }
        }
        return "Subscribe"
    }

    func purchaseSelectedPackage() {
        guard let package = selectedPackage else { return }
        isPurchasing = true
        
        revenueCatService.purchase(package: package) { success in
            isPurchasing = false
            if success {
                viewModel.completeOnboarding()
            } else {
                errorMessage = "Purchase failed or was cancelled."
                showError = true
            }
        }
    }
    
    func restorePurchases() {
        isPurchasing = true
        revenueCatService.restorePurchases { success in
            isPurchasing = false
            if success {
                viewModel.completeOnboarding()
            } else {
                errorMessage = "No active subscription found to restore."
                showError = true
            }
        }
    }
}

struct PackageOptionView: View {
    let package: Package
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.storeProduct.subscriptionPeriod?.unit == .year ? "Annual (Best Value)" : "Monthly")
                        .font(.bodyBold)
                        .foregroundColor(.textPrimary)
                    
                    if package.storeProduct.introductoryDiscount != nil {
                         Text("7 Days Free, then \(package.storeProduct.localizedPriceString)/\(package.storeProduct.subscriptionPeriod?.unit == .year ? "year" : "month")")
                             .font(.caption)
                             .foregroundColor(.textSecondary)
                    } else {
                        Text("\(package.storeProduct.localizedPriceString)/\(package.storeProduct.subscriptionPeriod?.unit == .year ? "year" : "month")")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primaryGreen)
                        .font(.iconRegular)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.iconRegular)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryGreen : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .background(isSelected ? Color.primaryGreen.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.iconRegular)
                .foregroundColor(.primaryGreen)
                .frame(width: 30)
            
            Text(text)
                .font(.bodyRegular)
            
            Spacer()
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(viewModel: OnboardingViewModel())
    }
}
