import SwiftUI

enum DesignSystem {
    // MARK: - Colors
    enum Colors {
        static let accent = Color.blue
        static let secondary = Color(.systemGray2)
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.systemGray6)
        static let text = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
    }
    
    // MARK: - Dimensions
    enum Dimensions {
        static let spacing: CGFloat = 16
        static let spacingSmall: CGFloat = 8
        static let spacingLarge: CGFloat = 24
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 50
        static let iconSize: CGFloat = 32
    }
    
    // MARK: - Typography
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title = Font.system(size: 28, weight: .bold)
        static let headline = Font.system(size: 20, weight: .semibold)
        static let body = Font.system(size: 17, weight: .regular)
        static let caption = Font.system(size: 15, weight: .regular)
    }
}

// MARK: - Custom ViewModifiers
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Dimensions.spacing)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius)
                    .fill(colorScheme == .dark ? DesignSystem.Colors.cardBackground : .white)
                    .shadow(radius: 8, y: 4)
            )
            .padding(.horizontal, DesignSystem.Dimensions.spacing)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Dimensions.buttonHeight)
            .background(DesignSystem.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Dimensions.cornerRadius))
            .shadow(radius: 4, y: 2)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }
} 