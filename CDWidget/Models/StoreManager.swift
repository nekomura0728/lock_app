import Foundation
import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    
    private let productIDs = ["com.lizaria.countdown.CDWidget.pro"]
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await requestProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            print("📦 StoreKit: \(products.count)個の商品を読み込み")
            for product in products {
                print("📦 商品: \(product.id) - \(product.displayPrice)")
            }
        } catch {
            errorMessage = "商品の読み込みに失敗しました: \(error.localizedDescription)"
            print("🚨 StoreKit Error: \(error)")
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedProducts()
                await transaction.finish()
                print("✅ 購入成功: \(product.id)")
                
            case .userCancelled:
                print("❌ ユーザーがキャンセル")
                
            case .pending:
                print("⏳ 購入が保留中")
                errorMessage = "購入が保留されています。後でもう一度お試しください。"
                
            @unknown default:
                break
            }
        } catch {
            errorMessage = "購入に失敗しました: \(error.localizedDescription)"
            print("🚨 Purchase Error: \(error)")
        }
        
        isPurchasing = false
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isPurchasing = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            print("🔄 購入復元完了")
        } catch {
            errorMessage = "購入の復元に失敗しました: \(error.localizedDescription)"
            print("🚨 Restore Error: \(error)")
        }
        
        isPurchasing = false
    }
    
    // MARK: - Private Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("🚨 Transaction Error: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func updatePurchasedProducts() async {
        var purchasedProductIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedProductIDs.insert(transaction.productID)
            } catch {
                print("🚨 Transaction Verification Error: \(error)")
            }
        }
        
        self.purchasedProductIDs = purchasedProductIDs
    }
    
    // MARK: - Helper Properties
    
    var proProduct: Product? {
        return products.first { $0.id == "com.lizaria.countdown.CDWidget.pro" }
    }
    
    var isPro: Bool {
        return purchasedProductIDs.contains("com.lizaria.countdown.CDWidget.pro")
    }
}

enum StoreError: Error, LocalizedError {
    case failedVerification
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "購入の検証に失敗しました。"
        }
    }
}