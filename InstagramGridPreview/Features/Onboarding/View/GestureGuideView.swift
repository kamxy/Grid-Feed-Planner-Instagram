import SwiftUI

struct GestureGuideView: View {
    let guide: GestureGuide
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Gesture Animation
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                gestureAnimation
            }
            .frame(height: 120)
            
            // Guide Text
            VStack(spacing: 8) {
                Text(guide.title)
                    .font(.headline)
                
                Text(guide.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // Dismiss Button
            Button("Got it") {
                withAnimation(.spring()) {
                    isVisible = false
                }
                onDismiss()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 50)
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
            }
            startGestureAnimation()
        }
    }
    
    @ViewBuilder
    private var gestureAnimation: some View {
        switch guide.gestureType {
        case .tap:
            tapAnimation
        case .longPress:
            longPressAnimation
        case .drag:
            dragAnimation
        case .pinch:
            pinchAnimation
        case .swipe(let edge):
            swipeAnimation(from: edge)
        }
    }
    
    private var tapAnimation: some View {
        Circle()
            .stroke(Color.accentColor, lineWidth: 2)
            .frame(width: 44, height: 44)
            .scaleEffect(1 + animationProgress * 0.3)
            .opacity(1 - animationProgress)
    }
    
    private var longPressAnimation: some View {
        Circle()
            .stroke(Color.accentColor, lineWidth: 2)
            .frame(width: 44, height: 44)
            .scaleEffect(1 + animationProgress * 0.5)
            .opacity(1)
    }
    
    private var dragAnimation: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 44, height: 44)
            .offset(x: animationProgress * 60 - 30, y: 0)
    }
    
    private var pinchAnimation: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: 44, height: 44)
                .scaleEffect(1 + animationProgress)
            
            Circle()
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(width: 44, height: 44)
                .scaleEffect(1 - animationProgress * 0.5)
        }
    }
    
    private func swipeAnimation(from edge: Edge) -> some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 44, height: 44)
            .offset(y: edge == .bottom ? (animationProgress * 60 - 30) : 0)
            .offset(x: edge == .trailing ? (animationProgress * 60 - 30) : 0)
    }
    
    private func startGestureAnimation() {
        withAnimation(
            Animation
                .easeInOut(duration: guide.animationDuration)
                .repeatCount(guide.repeatCount, autoreverses: true)
        ) {
            animationProgress = 1
        }
    }
}

struct GestureGuideModifier: ViewModifier {
    @ObservedObject private var gestureGuideService = GestureGuideService.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if let guide = gestureGuideService.currentGuide {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            GestureGuideView(guide: guide) {
                                gestureGuideService.dismissCurrentGuide()
                            }
                            .padding()
                        )
                }
            }
        )
    }
}

extension View {
    func gestureGuide() -> some View {
        modifier(GestureGuideModifier())
    }
} 