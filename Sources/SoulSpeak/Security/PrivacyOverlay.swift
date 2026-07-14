import SwiftUI

struct PrivacyOverlayView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(0.95)
            
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundColor(SSColors.primary)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text("SoulSpeak")
                    .font(SSTypography.title)
                    .foregroundColor(.white)
                
                Text("Your privacy is protected")
                    .font(SSTypography.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onAppear {
            isAnimating = true
        }
        .transition(.opacity)
    }
}
