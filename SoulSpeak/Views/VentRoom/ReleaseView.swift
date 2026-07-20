import SwiftUI

/// Release screen — room resets with a healing animation.
/// The destruction fades, peace returns.
struct ReleaseView: View {
    let onComplete: () -> Void
    let onExit: () -> Void

    @State private var healingGlow = false
    @State private var textOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0
    @State private var particlePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Peaceful gradient — opposite of destruction
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.15),
                    Color(red: 0.08, green: 0.15, blue: 0.12),
                    Color(red: 0.05, green: 0.1, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Healing particles
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.4))
                    .frame(width: CGFloat.random(in: 4...10))
                    .offset(
                        x: CGFloat.random(in: -180...180),
                        y: sin(particlePhase + CGFloat(i)) * 150
                    )
                    .opacity(healingGlow ? 0.6 : 0.2)
            }

            // Central glow
            RadialGradient(
                colors: [
                    Color(red: 0.3, green: 0.8, blue: 0.5).opacity(healingGlow ? 0.2 : 0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 30,
                endRadius: 300
            )

            VStack(spacing: 28) {
                Spacer()

                // Leaf icon
                Image(systemName: "leaf.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                    .scaleEffect(healingGlow ? 1.1 : 1.0)

                Text("Released.")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .opacity(textOpacity)

                Text("The room is restored.\nYour spirit is lighter.")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)

                Spacer()

                // Action buttons
                VStack(spacing: 14) {
                    Button(action: onComplete) {
                        Text("Vent Again")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }

                    Button(action: onExit) {
                        Text("I'm done — leave room")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.2, green: 0.6, blue: 0.4), Color(red: 0.15, green: 0.5, blue: 0.35)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
                .padding(.horizontal, 30)
                .opacity(buttonsOpacity)

                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            startHealingAnimations()
        }
    }

    private func startHealingAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            healingGlow = true
        }
        withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
            particlePhase = .pi * 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.8)) { textOpacity = 1.0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn(duration: 0.6)) { buttonsOpacity = 1.0 }
        }
    }
}
