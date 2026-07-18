import SwiftUI

/// Main tab navigation with 5 tabs: Journal, Mood, Analytics, Prayer, Settings.
struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var audioPlayer = AudioPlayerService.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            // Voice Journal tab
            NavigationStack {
                VoiceJournalView()
            }
            .tabItem {
                Image(systemName: "mic.fill")
                Text("Journal")
            }
            .tag(0)

            // Mood Tracker tab
            NavigationStack {
                MoodTrackerView()
            }
            .tabItem {
                Image(systemName: "face.smiling.fill")
                Text("Mood")
            }
            .tag(1)

            // Analytics tab
            NavigationStack {
                AnalyticsView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Analytics")
            }
            .tag(2)

            // Prayer/Outro tab
            NavigationStack {
                PrayerOutroView()
            }
            .tabItem {
                Image(systemName: "hands.and.sparkles.fill")
                Text("Prayer")
            }
            .tag(3)

            // Settings tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(4)
        }
        .tint(SSColors.primary)
        .onAppear {
            // Start ambient jazz in background
            audioPlayer.playBackgroundMusic(fileName: "jazz_loop_2")
        }
    }
}
