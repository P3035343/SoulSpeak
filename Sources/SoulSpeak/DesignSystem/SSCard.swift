import SwiftUI

struct SSCard<Content: View>: View {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let content: () -> Content
    
    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 4,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(SSColors.surface)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, x: 0, y: 2)
    }
}

struct SSGradientCard<Content: View>: View {
    let gradient: LinearGradient
    let padding: CGFloat
    let cornerRadius: CGFloat
    let content: () -> Content
    
    init(
        gradient: LinearGradient = SSColors.gradientPrimary,
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.gradient = gradient
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(gradient)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}
