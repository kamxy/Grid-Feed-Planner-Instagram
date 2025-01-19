import SwiftUI

struct QuickTipView: View {
    let tip: OnboardingTip
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text(tip.title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
            }
        }
    }
}

struct QuickTipModifier: ViewModifier {
    @ObservedObject private var onboardingService = OnboardingService.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if let tip = onboardingService.currentTip {
                    VStack {
                        Spacer()
                        QuickTipView(tip: tip) {
                            onboardingService.dismissCurrentTip()
                        }
                    }
                }
            }
        )
    }
}

extension View {
    func quickTip() -> some View {
        modifier(QuickTipModifier())
    }
} 