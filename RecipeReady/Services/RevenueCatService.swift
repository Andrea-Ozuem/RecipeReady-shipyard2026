import Foundation
import RevenueCat
import Combine

class RevenueCatService: NSObject, ObservableObject {
    static let shared = RevenueCatService()
    
    @Published var isPro: Bool = false
    @Published var currentOffering: Offering?
    @Published var retentionOffering: Offering?
    @Published var customerInfo: CustomerInfo?
    
    override private init() {
        super.init()
    }
    
    func configure() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Secrets.revenueCatApiKey)
        
        Purchases.shared.delegate = self
        
        // Fetch initial info
        fetchCustomerInfo()
        fetchOfferings()
    }
    
    func fetchCustomerInfo() {
        Purchases.shared.getCustomerInfo { [weak self] (info, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching customer info: \(error.localizedDescription)")
            } else if let info = info {
                self.updateCustomerStatus(info: info)
            }
        }
    }
    
    func fetchOfferings() {
        Purchases.shared.getOfferings { [weak self] (offerings, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching offerings: \(error.localizedDescription)")
            } else if let offerings = offerings {
                // We can choose 'current' or specific offering based on logic later
                DispatchQueue.main.async {
                    self.currentOffering = offerings.current
                    self.retentionOffering = offerings.offering(identifier: "retention")
                }
            }
        }
    }
    
    func purchase(package: Package, completion: @escaping (Bool) -> Void) {
        Purchases.shared.purchase(package: package) { [weak self] (transaction, customerInfo, error, userCancelled) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error purchasing: \(error.localizedDescription)")
                completion(false)
            } else if !userCancelled, let customerInfo = customerInfo {
                self.updateCustomerStatus(info: customerInfo)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error restoring purchases: \(error.localizedDescription)")
                completion(false)
            } else if let customerInfo = customerInfo {
                self.updateCustomerStatus(info: customerInfo)
                // Check if they actually have the entitlement after restore
                let hasEntitlement = customerInfo.entitlements["Recipe Ready Pro"]?.isActive == true
                completion(hasEntitlement)
            }
        }
    }
    
    private func updateCustomerStatus(info: CustomerInfo) {
        DispatchQueue.main.async {
            self.customerInfo = info
            self.isPro = info.entitlements["Recipe Ready Pro"]?.isActive == true
        }
    }
}

extension RevenueCatService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        updateCustomerStatus(info: customerInfo)
    }
}
