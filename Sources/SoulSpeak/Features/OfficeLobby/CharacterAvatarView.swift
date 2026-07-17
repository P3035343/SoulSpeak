import SwiftUI

/// Animated avatar card for a Hope character in the lobby.
struct CharacterAvatarView: View {
    let character: HopeCharacter
    let onTap: () -> Void
    
    @State private var isBreathing = false
    @State private var isHovered = false
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Avatar circle with breathing animation
                ZStack {
                    // Glow ring
                    Circle()
                        .fill(character.avatarColor.opacity(glowOpacity))
                        .frame(width: 130, height: 130)
                        .scaleEffect(isBreathing ? 1.1 : 1.0)
                    
                    // Avatar background
                    Circle()
                        .fill(character.backgroundGradient)
                        .frame(width: 110, height: 110)
                        .shadow(color: character.avatarColor.opacity(0.4), radius: 8, y: 4)
                    
                    // Avatar image or SF Symbol fallback
                    if let imageName = character.avatarImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .scaleEffect(isBreathing ? 1.03 : 1.0)
                    } else {
                        Image(systemName: character.avatarIcon)
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
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
                
                // "Available" indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .fill(Color.green.opacity(0.4))
                                .frame(width: 14, height: 14)
                                .scaleEffect(isBreathing ? 1.2 : 0.8)
                        )
                    Text("Available")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.9))
                    .shadow(color: character.avatarColor.opacity(isHovered ? 0.3 : 0.1), radius: isHovered ? 12 : 6, y: isHovered ? 6 : 3)
            )
            .scaleEffect(isHovered ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isBreathing = true
                glowOpacity = 0.5
            }
        }
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = pressing
            }
        }, perform: {})
    }
}
