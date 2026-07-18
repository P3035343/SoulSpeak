import SwiftUI
import SwiftData

/// Root content view — shows Welcome screen first, then main tab navigation.
/// No lock screen; app goes straight to content.
struct ContentView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcome = true
    @Query private var settings: [UserSettings]

    var body: some View {
        ZStack {
            if showWelcome && !hasSeenWelcome {
                WelcomeView(showWelcome: $showWelcome)
                    .transition(.opacity)
                    .onChange(of: showWelcome) { _, newValue in
                        if !newValue {
                            hasSeenWelcome = true
                        }
                    }
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showWelcome)
        .onAppear {
            // If user has seen welcome before, skip it
            if hasSeenWelcome {
                showWelcome = false
            }
            // Disable idle timer (no lock screen)
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .preferredColorScheme(settings.first?.isDarkMode == true ? .dark : .light)
    }
}
