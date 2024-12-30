import StoreKit

class StoreKitManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    private let productIdentifiers = ["com.yourdomain.instagramgridpreview.pro"] // Add your product IDs
    
    init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
        
        // Listen for transactions in real-time
        listenForTransactions()
    }
    
    @MainActor
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIdentifiers)
        } catch {
            print("Failed to load products:", error)
        }
    }
    
    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                await self.handle(transaction: result)
            }
        }
    }
    
    @MainActor
    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }
    
    @MainActor
    private func handle(transaction result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else {
            // Invalid transaction
            return
        }
        
        // Handle transaction
        if transaction.revocationDate == nil {
            purchasedProductIDs.insert(transaction.productID)
        } else {
            purchasedProductIDs.remove(transaction.productID)
        }
        
        await transaction.finish()
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            await handle(transaction: verification)
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
} 