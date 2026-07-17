import SwiftUI

/// Animated avatar card for a Hope character in the lobby.
/// Features breathing animation, glow effects, and engagement indicators.
struct CharacterAvatarView: View {
    let character: HopeCharacter
    let onTap: () -> Void
    
    @State private var isBreathing = false
    @State private var isHovered = false
    @State private var glowOpacity: Double = 0.3
    @State private var avatarOffset: CGFloat = 0
    @State private var waveHand = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Avatar with animations
                ZStack {
                    // Outer glow ring - breathing
                    Circle()
                        .fill(character.avatarColor.opacity(glowOpacity))
                        .frame(width: 140, height: 140)
                        .scaleEffect(isBreathing ? 1.15 : 1.0)
                    
                    // Middle ring
                    Circle()
                        .stroke(character.avatarColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 125, height: 125)
                        .scaleEffect(isBreathing ? 1.05 : 0.95)
                    
                    // Avatar image or fallback
                    if let imageName = character.avatarImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(character.avatarColor, lineWidth: 3)
                            )
                            .shadow(color: character.avatarColor.opacity(0.5), radius: 10, y: 4)
                            // Subtle head movement
                            .offset(y: avatarOffset)
                            .rotation3DEffect(
                                .degrees(isBreathing ? 2 : -2),
                                axis: (x: 0, y: 1, z: 0)
                            )
                    } else {
                        Circle()
                            .fill(character.backgroundGradient)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Image(systemName: character.avatarIcon)
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: character.avatarColor.opacity(0.5), radius: 10, y: 4)
                            .offset(y: avatarOffset)
                    }
                    
                    // "Waving" indicator
                    if waveHand {
                        Text("👋")
                            .font(.system(size: 28))
                            .offset(x: 50, y: -40)
                            .rotationEffect(.degrees(waveHand ? 20 : -20))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Name plate
                VStack(spacing: 4) {
                    Text(character.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text(character.subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // "Available" with animated dot
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .fill(Color.green.opacity(0.4))
                                .frame(width: 16, height: 16)
                                .scaleEffect(isBreathing ? 1.3 : 0.7)
                        )
                    Text("Tap to talk")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.9))
                    .shadow(color: character.avatarColor.opacity(isHovered ? 0.4 : 0.15), radius: isHovered ? 16 : 8, y: isHovered ? 8 : 4)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .onAppear {
            // Breathing animation
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isBreathing = true
                glowOpacity = 0.5
            }
            // Subtle head bob
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                avatarOffset = -3
            }
            // Wave after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    waveHand = true
                }
                // Hide wave after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        waveHand = false
                    }
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = pressing
            }
        }, perform: {})
    }
}

/// Animated avatar shown during conversation - simulates talking.
struct TalkingAvatarView: View {
    let character: HopeCharacter
    let isSpeaking: Bool
    
    @State private var mouthOpen = false
    @State private var headTilt: Double = 0
    @State private var eyeBlink = false
    @State private var nodding = false
    
    var body: some View {
        ZStack {
            // Avatar image
            if let imageName = character.avatarImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(character.avatarColor, lineWidth: 2)
                    )
                    // Nodding when speaking
                    .offset(y: nodding ? -2 : 2)
                    .rotation3DEffect(
                        .degrees(headTilt),
                        axis: (x: 0.1, y: 1, z: 0)
                    )
                    // Speaking glow
                    .shadow(
                        color: isSpeaking ? character.avatarColor.opacity(0.6) : Color.clear,
                        radius: isSpeaking ? 8 : 0
                    )
                    // Overlay for "talking" effect - subtle pulse
                    .overlay(
                        Circle()
                            .stroke(character.avatarColor.opacity(isSpeaking ? 0.5 : 0), lineWidth: 2)
                            .scaleEffect(mouthOpen ? 1.15 : 1.0)
                    )
            } else {
                Circle()
                    .fill(character.backgroundGradient)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: character.avatarIcon)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                    .offset(y: nodding ? -2 : 2)
            }
            
            // Sound wave indicator when speaking
            if isSpeaking {
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(character.avatarColor)
                            .frame(width: 3, height: mouthOpen ? CGFloat(8 + index * 4) : 4)
                    }
                }
                .offset(x: 38, y: 0)
            }
        }
        .onChange(of: isSpeaking) { _, speaking in
            if speaking {
                startSpeakingAnimation()
            } else {
                stopSpeakingAnimation()
            }
        }
        .onAppear {
            if isSpeaking {
                startSpeakingAnimation()
            }
        }
    }
    
    private func startSpeakingAnimation() {
        // Mouth/pulse animation
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            mouthOpen = true
        }
        // Head movement
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            headTilt = 3
            nodding = true
        }
    }
    
    private func stopSpeakingAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            mouthOpen = false
            headTilt = 0
            nodding = false
        }
    }
}
