import SwiftUI
import StoreKit

struct PremiumView: View {
    @EnvironmentObject private var storeKit: StoreKitManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedFeatureIndex = 0
    
    // Animation properties
    @State private var isAnimating = false
    
    private let features = [
        (icon: "photo.stack.fill", text: "premium.feature.unlimited", color: Color.blue),
        (icon: "arrow.up.square.fill", text: "premium.feature.export", color: Color.purple),
        (icon: "calendar.badge.clock", text: "premium.feature.planning", color: Color.orange),
        (icon: "paintbrush.fill", text: "premium.feature.filters", color: Color.green)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Dimensions.spacingLarge) {
                    // Animated Header
                    VStack(spacing: DesignSystem.Dimensions.spacing) {
                        Image(systemName: "star.circle.fill") 
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .padding(.top, DesignSystem.Dimensions.spacingLarge)
                        
                        Text("premium.title")
                            .font(DesignSystem.Typography.largeTitle)
                            .multilineTextAlignment(.center)
                            .gradientForeground(colors: [.blue, .purple])
                        
                        Text("premium.subtitle")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .opacity(isAnimating ? 1 : 0)
                    }
                    
                    // Features List with Animation
                    VStack(alignment: .leading, spacing: DesignSystem.Dimensions.spacing) {
                        ForEach(Array(features.enumerated()), id: \.element.text) { index, feature in
                            FeatureRow(
                                icon: feature.icon,
                                text: feature.text,
                                color: feature.color,
                                isSelected: selectedFeatureIndex == index
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedFeatureIndex = index
                                }
                            }
                        }
                    }
                    .cardStyle()
                    
                    // Purchase Button Section
                    VStack(spacing: DesignSystem.Dimensions.spacing) {
                        if let product = storeKit.products.first {
                            PurchaseButton(product: product)
                                .padding(.horizontal)
                        } else {
                            ProgressView()
                        }
                        
                        Button("premium.restore") {
                            Task {
                                await storeKit.updatePurchasedProducts()
                            }
                        }
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                .padding(.bottom, DesignSystem.Dimensions.spacingLarge)
            }
            .navigationBarItems(trailing: CloseButton())
            .background(
                LinearGradient(
                    colors: [
                        colorScheme == .dark ? Color.black : Color.white,
                        colorScheme == .dark ? Color.black.opacity(0.8) : Color.blue.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
}

// Supporting Views
private struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Dimensions.spacing) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: DesignSystem.Dimensions.iconSize)
                .scaleEffect(isSelected ? 1.1 : 1.0)
            
            Text(LocalizedStringKey(text))
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.text)
        }
        .padding(.vertical, DesignSystem.Dimensions.spacingSmall)
        .padding(.horizontal, DesignSystem.Dimensions.spacing)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius / 2)
                .fill(color.opacity(isSelected ? 0.1 : 0))
        )
        .animation(.spring(), value: isSelected)
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
            HStack {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("premium.upgrade.button \(product.displayPrice)")
                        .bold()
                }
            }
        }
        .primaryButtonStyle()
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius)
                .stroke(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing), lineWidth: 2)
        )
        .disabled(isPurchasing)
    }
}

// Add gradient foreground modifier
extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
        .mask(self)
    }
}

private struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(DesignSystem.Colors.secondary)
        }
    }
}

#Preview {
    PremiumView()
        .environmentObject(StoreKitManager())
} 