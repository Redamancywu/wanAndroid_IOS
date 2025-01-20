import SwiftUI

struct TapFeedback: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
                pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
    }
}

extension View {
    func withTapFeedback() -> some View {
        modifier(TapFeedback())
    }
}

struct TapFeedback_Previews: PreviewProvider {
    static var previews: some View {
        Button("点击我") { }
            .withTapFeedback()
            .environmentObject(UserState.shared)
    }
} 