import StoreKit
import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject private var storeKit: StoreKitManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                Text("Upgrade to Pro")
                    .font(.largeTitle)
                    .bold()
                
                // Features List
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "photo.stack", text: "Unlimited Grid Previews")
                    FeatureRow(icon: "arrow.up.square", text: "Export in High Resolution")
                    FeatureRow(icon: "calendar", text: "Advanced Planning Tools")
                    FeatureRow(icon: "paintbrush", text: "Premium Filters")
                }
                .padding()
                
                Spacer()
                
                // Purchase Button
                if let product = storeKit.products.first {
                    PurchaseButton(product: product)
                } else {
                    ProgressView()
                }
                
                // Restore Purchases Button
                Button("Restore Purchases") {
                    Task {
                        await storeKit.updatePurchasedProducts()
                    }
                }
                .foregroundColor(.secondary)
                .padding(.top)
            }
            .padding()
            .navigationBarItems(trailing: CloseButton())
        }
    }
}

// Supporting Views
private struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
        }
    }
}

private struct PurchaseButton: View {
    let product: Product
    @EnvironmentObject private var storeKit: StoreKitManager
    @State private var isPurchasing = false
    
    var body: some View {
        Button {
            Task {
                isPurchasing = true
                do {
                    try await storeKit.purchase(product)
                } catch {
                    print("Purchase failed: \(error)")
                }
                isPurchasing = false
            }
        } label: {
            if isPurchasing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Upgrade for \(product.displayPrice)")
                    .bold()
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isPurchasing)
    }
}

private struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.gray)
                .font(.title2)
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(StoreKitManager())
}
