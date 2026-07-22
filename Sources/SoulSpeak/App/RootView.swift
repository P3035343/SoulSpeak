import SwiftUI

struct RootView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var hasEnteredOffice = false

    var body: some View {
        if !hasEnteredOffice {
            WelcomeScreen(onEnter: {
                withAnimation(.easeInOut(duration: 0.6)) {
                    hasEnteredOffice = true
                }
            })
        } else {
            MainTabView()
        }
    }
}

struct WelcomeScreen: View {
    let onEnter: () -> Void
    @State private var animate = false
    @State private var showText = false
    @StateObject private var audioPlayer = AudioPlayerService.shared

    var body: some View {
        ZStack {
            // Mr. Hope's office background
            Image("mr_hope_office")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.3))

            // Fallback gradient if image not found
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.1, blue: 0.05), Color(red: 0.3, green: 0.2, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(0.5)

            VStack(spacing: 32) {
                Spacer()

                // Mr. Hope avatar
                Image("mr_hope")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 3))
                    .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
                    .scaleEffect(animate ? 1.02 : 0.98)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)

                // Greeting
                VStack(spacing: 12) {
                    Text("Mr. Hope")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    Text("\"Dr. Hope will see you\nshortly, Champ.\"")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1 : 0)
                }

                Spacer()

                // Enter button
                Button(action: {
                    onEnter()
                }) {
                    Text("Start Journaling")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule().fill(SSColors.primary)
                                .shadow(color: SSColors.primary.opacity(0.5), radius: 8, y: 4)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            animate = true
            // Play Mr. Hope greeting
            audioPlayer.playVoice(fileName: "mr_hope_greeting")
            // Fade in text
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                showText = true
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            VoiceJournalScreen()
                .tabItem {
                    Label("Journal", systemImage: "mic.fill")
                }
                .tag(0)

            MoodTrackerScreen()
                .tabItem {
                    Label("Mood", systemImage: "heart.fill")
                }
                .tag(1)

            AnalyticsScreen()
                .tabItem {
                    Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            PrayerScreen()
                .tabItem {
                    Label("Prayer", systemImage: "hands.clap.fill")
                }
                .tag(3)

            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(SSColors.primary)
    }
}
