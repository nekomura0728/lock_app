import SwiftUI

// MARK: - Animation Extensions

extension Animation {
    static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeOut(duration: 0.2)
    static let gentle = Animation.easeInOut(duration: 0.5)
}

// MARK: - Custom Transitions

extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    static var scaleAndFade: AnyTransition {
        .scale.combined(with: .opacity)
    }
    
    static var slideUp: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
}

// MARK: - View Modifiers

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.bouncy, value: configuration.isPressed)
    }
}

struct FloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.quick, value: configuration.isPressed)
    }
}

// MARK: - Loading Animations

struct LoadingDotsView: View {
    @State private var animatingIndex = 0
    let dotCount = 3
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animatingIndex == index ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.5), value: animatingIndex)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation {
                animatingIndex = (animatingIndex + 1) % dotCount
            }
        }
    }
}

// MARK: - Success Animation

struct SuccessCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0.2, y: 0.5))
            path.addLine(to: CGPoint(x: 0.4, y: 0.7))
            path.addLine(to: CGPoint(x: 0.8, y: 0.3))
        }
        .trim(from: 0, to: trimEnd)
        .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        .frame(width: 30, height: 30)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                trimEnd = 1
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    func shake(offset: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: offset))
    }
    
    func pulse() -> some View {
        modifier(PulseEffect())
    }
    
    func springButton() -> some View {
        buttonStyle(SpringButtonStyle())
    }
    
    func floatingButton() -> some View {
        buttonStyle(FloatingButtonStyle())
    }
    
    func slideAndFadeTransition() -> some View {
        transition(.slideAndFade)
    }
    
    func scaleAndFadeTransition() -> some View {
        transition(.scaleAndFade)
    }
    
    func slideUpTransition() -> some View {
        transition(.slideUp)
    }
}

// MARK: - Haptic Feedback

struct HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}