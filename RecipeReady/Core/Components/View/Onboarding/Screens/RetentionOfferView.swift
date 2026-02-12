import SwiftUI
import RevenueCat

/// A standalone retention offer view shown in specific scenarios
/// (e.g. when a user tries to cancel or has been inactive).
/// This uses the "retention" offering configured in RevenueCat.
struct RetentionOfferView: View {
    @EnvironmentObject var revenueCatService: RevenueCatService
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var onPurchaseCompleted: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.primaryGreen)
                            .padding(.top, 40)
                        
                        Text("Wait — we have a special offer!")
                            .font(.heading1)
                            .multilineTextAlignment(.center)
                        
                        Text("Before you go, here's an exclusive deal just for you.")
                            .font(.bodyRegular)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    if let retentionOffering = revenueCatService.retentionOffering,
                       let retentionPackage = retentionOffering.availablePackages.first {
                        
                        // Offer Card
                        VStack(spacing: 16) {
                            HStack {
                                Text("🎉")
                                    .font(.system(size: 28))
                                Text("Special Offer")
                                    .font(.heading2)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                if retentionPackage.storeProduct.introductoryDiscount != nil {
                                    Text("3 Days Free Trial")
                                        .font(.bodyBold)
                                        .foregroundColor(.white)
                                }
                                
                                Text("Then \(retentionPackage.storeProduct.localizedPriceString)/year")
                                    .font(.bodyRegular)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.primaryGreen)
                                .shadow(color: Color.primaryGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // Features reminder
                        VStack(spacing: 20) {
                            FeatureRow(icon: "wand.and.stars", text: "Unlimited AI Recipe Extraction")
                            FeatureRow(icon: "folder.fill", text: "Unlimited Cookbooks")
                            FeatureRow(icon: "list.bullet.rectangle.portrait.fill", text: "Smart Grocery Lists")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                    } else if let errorMessage = revenueCatService.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            Text("Error Loading Offer")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            Button(action: {
                                revenueCatService.errorMessage = nil
                                revenueCatService.fetchOfferings()
                            }) {
                                Text("Retry")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(Color.primaryGreen)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    } else {
                        ProgressView("Loading offer...")
                            .padding()
                    }
                }
            }
            
            // Fixed Bottom
            VStack(spacing: 16) {
                if let retentionOffering = revenueCatService.retentionOffering,
                   let retentionPackage = retentionOffering.availablePackages.first {
                    
                    Button(action: { purchaseRetention(package: retentionPackage) }) {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Claim This Offer")
                                    .font(.bodyBold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(isPurchasing)
                }
                
                Button("No thanks") {
                    dismiss()
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
    
    private func purchaseRetention(package: Package) {
        isPurchasing = true
        revenueCatService.purchase(package: package) { success in
            isPurchasing = false
            if success {
                onPurchaseCompleted?()
                dismiss()
            } else {
                errorMessage = "Purchase failed or was cancelled."
                showError = true
            }
        }
    }
}

// MARK: - Supporting Components

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

struct RetentionOfferView_Previews: PreviewProvider {
    static var previews: some View {
        RetentionOfferView()
            .environmentObject(RevenueCatService.shared)
    }
}
