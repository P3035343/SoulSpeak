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
                .allowsHitTesting(false)

            // Stronger dark overlay for better icon visibility
            VStack {
                Spacer()
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 350)
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Content overlay
            VStack {
                // Top bar: Settings (left) + Emergency (right)
                HStack {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Button(action: { showEmergency = true }) {
                        Image(systemName: "sos.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.red)
                            .shadow(color: .red.opacity(0.6), radius: 10)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 60)

                Spacer()

                // Main navigation icons — bigger, bolder, more visible
                VStack(spacing: 24) {
                    // Top row
                    HStack(spacing: 28) {
                        hubIcon(
                            name: "Journal",
                            icon: "mic.fill",
                            color: Color(red: 0.8, green: 0.4, blue: 0.9),
                            action: { showJournal = true }
                        )

                        hubIcon(
                            name: "Talk",
                            icon: "bubble.left.and.bubble.right.fill",
                            color: Color(red: 0.3, green: 0.6, blue: 1.0),
                            action: { showTalk = true }
                        )

                        hubIcon(
                            name: "Vent",
                            icon: "flame.fill",
                            color: Color(red: 1.0, green: 0.4, blue: 0.15),
                            action: { showVent = true }
                        )
                    }

                    // Bottom row
                    HStack(spacing: 28) {
                        hubIcon(
                            name: "Centered",
                            icon: "leaf.circle.fill",
                            color: Color(red: 0.3, green: 0.85, blue: 0.5),
                            action: { showCentered = true }
                        )

                        hubIcon(
                            name: "Mood",
                            icon: "face.smiling.fill",
                            color: Color(red: 1.0, green: 0.75, blue: 0.2),
                            action: { showMood = true }
                        )

                        hubIcon(
                            name: "More",
                            icon: "ellipsis.circle.fill",
                            color: Color.white,
                            action: { showSettings = true }
                        )
                    }
                }
                .padding(.bottom, 70)
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

    // MARK: - Hub Icon (larger, more vibrant, dark solid background)
    private func hubIcon(name: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Dark solid circle background for contrast
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 74, height: 74)

                    // Colored ring
                    Circle()
                        .stroke(color, lineWidth: 3)
                        .frame(width: 74, height: 74)
                        .shadow(color: color.opacity(pulseGlow ? 0.7 : 0.3), radius: 10)

                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
            }
        }
    }
}
