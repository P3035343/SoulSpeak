import SwiftUI

/// The Office Lobby — first-person immersive scene
/// where users walk in and choose to speak with Mr. Hope or Dr. Hope.
struct OfficeLobbyView: View {
    @State private var hasEntered = false
    @State private var selectedCharacter: HopeCharacter?
    @State private var showConversation = false
    @State private var doorOpacity: Double = 1.0
    @State private var roomScale: CGFloat = 0.8
    @State private var welcomeTextOpacity: Double = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient - warm office atmosphere
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.92, blue: 0.88),
                        Color(red: 0.88, green: 0.85, blue: 0.80)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if !hasEntered {
                    entranceScene
                } else if let character = selectedCharacter {
                    if showConversation {
                        ConversationView(character: character, onExit: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showConversation = false
                                selectedCharacter = nil
                            }
                        })
                        .transition(.opacity.combined(with: .scale))
                    } else {
                        characterSelectionScene
                    }
                } else {
                    characterSelectionScene
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Entrance Animation Scene
    private var entranceScene: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Door animation
            ZStack {
                // Door frame
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.45, green: 0.3, blue: 0.2))
                    .frame(width: 160, height: 240)
                    .shadow(radius: 10)
                
                // Door
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.55, green: 0.38, blue: 0.25))
                    .frame(width: 140, height: 220)
                    .opacity(doorOpacity)
                    .overlay(
                        // Door handle
                        Circle()
                            .fill(Color.yellow.opacity(0.8))
                            .frame(width: 14, height: 14)
                            .offset(x: 50, y: 10)
                    )
                
                // Light through door
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 140, height: 220)
                    .opacity(1 - doorOpacity)
            }
            
            // Sign
            VStack(spacing: 8) {
                Text("The Hope Office")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.2))
                
                Text("A safe space for reflection")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
            }
            .opacity(doorOpacity)
            
            Spacer()
            
            // Enter button
            Button(action: enterOffice) {
                HStack(spacing: 12) {
                    Image(systemName: "door.left.hand.open")
                        .font(.system(size: 20))
                    Text("Enter the Office")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.vertical, 18)
                .padding(.horizontal, 40)
                .background(
                    Capsule()
                        .fill(SSColors.primary)
                        .shadow(color: SSColors.primary.opacity(0.4), radius: 8, y: 4)
                )
            }
            .padding(.bottom, 60)
        }
    }
    
    // MARK: - Character Selection Scene
    private var characterSelectionScene: some View {
        VStack(spacing: 24) {
            // Room entered text
            Text("Welcome")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.2))
                .opacity(welcomeTextOpacity)
            
            Text("Who would you like to see today?")
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.secondary)
                .opacity(welcomeTextOpacity)
            
            Spacer()
            
            // Two chairs/desks with avatars
            HStack(spacing: 24) {
                CharacterAvatarView(
                    character: .mrHope,
                    onTap: {
                        selectedCharacter = .mrHope
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showConversation = true
                        }
                    }
                )
                
                CharacterAvatarView(
                    character: .drHope,
                    onTap: {
                        selectedCharacter = .drHope
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showConversation = true
                        }
                    }
                )
            }
            .scaleEffect(roomScale)
            
            Spacer()
            
            // Exit button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    hasEntered = false
                    doorOpacity = 1.0
                    roomScale = 0.8
                    welcomeTextOpacity = 0
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                    Text("Leave Office")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
        }
        .padding()
    }
    
    // MARK: - Actions
    private func enterOffice() {
        // Door opening animation
        withAnimation(.easeInOut(duration: 0.8)) {
            doorOpacity = 0.0
        }
        
        // Transition to room
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                hasEntered = true
                roomScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                welcomeTextOpacity = 1.0
            }
        }
    }
}
