import SwiftUI

/// Main Hub — Beautiful lobby room as the home screen.
/// After the intro video, this is what the user sees.
/// Icons overlay on the room image. Tapping each opens its door scene.
///
/// Image needed: "main_lobby" in Assets.xcassets
/// (The warm office room with brick walls, books, plants, leather chair)
struct MainHubView: View {
    @State private var showJournal = false
    @State private var showTalk = false
    @State private var showVent = false
    @State private var showCentered = false
    @State private var showMood = false
    @State private var showEmergency = false
    @State private var showSettings = false
    @State private var pulseGlow = false

    var body: some View {
        ZStack {
            // Beautiful lobby background (full screen)
            Image("main_lobby")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()

            // Subtle dark overlay at bottom for icons
            VStack {
                Spacer()
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
            }
            .ignoresSafeArea()

            // Content overlay
            VStack {
                // Emergency button (top right)
                HStack {
                    Spacer()
                    Button(action: { showEmergency = true }) {
                        Image(systemName: "sos.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red.opacity(0.8))
                            .shadow(color: .red.opacity(0.4), radius: 8)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 60)
                }

                // Settings gear (top left)
                HStack {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.leading, 20)
                    Spacer()
                }

                Spacer()

                // Main navigation icons
                VStack(spacing: 20) {
                    // Top row
                    HStack(spacing: 30) {
                        hubIcon(
                            name: "Journal",
                            icon: "mic.fill",
                            color: Color(red: 0.7, green: 0.4, blue: 0.8),
                            action: { showJournal = true }
                        )

                        hubIcon(
                            name: "Talk",
                            icon: "bubble.left.and.bubble.right.fill",
                            color: Color(red: 0.3, green: 0.6, blue: 0.9),
                            action: { showTalk = true }
                        )

                        hubIcon(
                            name: "Vent",
                            icon: "flame.fill",
                            color: Color(red: 0.9, green: 0.4, blue: 0.2),
                            action: { showVent = true }
                        )
                    }

                    // Bottom row
                    HStack(spacing: 30) {
                        hubIcon(
                            name: "Centered",
                            icon: "leaf.circle.fill",
                            color: Color(red: 0.4, green: 0.7, blue: 0.5),
                            action: { showCentered = true }
                        )

                        hubIcon(
                            name: "Mood",
                            icon: "face.smiling.fill",
                            color: Color(red: 0.9, green: 0.7, blue: 0.3),
                            action: { showMood = true }
                        )

                        hubIcon(
                            name: "More",
                            icon: "ellipsis.circle.fill",
                            color: Color.white.opacity(0.7),
                            action: { showSettings = true }
                        )
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseGlow = true
            }
        }
        .fullScreenCover(isPresented: $showJournal) {
            NavigationStack { VoiceJournalView() }
        }
        .fullScreenCover(isPresented: $showTalk) {
            NavigationStack { TalkTabView(showConversation: .constant(false), selectedCharacter: .constant(.drHope)) }
        }
        .fullScreenCover(isPresented: $showVent) {
            VentRoomView()
        }
        .fullScreenCover(isPresented: $showCentered) {
            NavigationStack { CenteredView() }
        }
        .fullScreenCover(isPresented: $showMood) {
            NavigationStack { MoodTrackerView() }
        }
        .fullScreenCover(isPresented: $showEmergency) {
            EmergencyView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            NavigationStack { SettingsView() }
        }
    }

    // MARK: - Hub Icon
    private func hubIcon(name: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.4), lineWidth: 2)
                        )
                        .shadow(color: color.opacity(pulseGlow ? 0.4 : 0.1), radius: 8)

                    Image(systemName: icon)
                        .font(.system(size: 26))
                        .foregroundColor(color)
                }

                Text(name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}
