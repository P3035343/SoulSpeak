import SwiftUI
import SwiftData

/// Root content view — shows immersive video intro sequence first, then main tab navigation.
/// No lock screen; app goes straight to content.
///
/// Intro Flow:
/// 1. Mr. Hope video intro (greets user as "Champ", introduces Dr. Hope)
/// 2. Transition screen ("Dr. Hope will see you now...")
/// 3. Dr. Hope video intro (she introduces herself)
/// 4. "Begin Session" button → main app
struct ContentView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    @State private var introComplete = false
    @Query private var settings: [UserSettings]

    var body: some View {
        ZStack {
            if !introComplete && !hasSeenIntro {
                IntroSequenceView(introComplete: $introComplete)
                    .transition(.opacity)
                    .onChange(of: introComplete) { _, newValue in
                        if newValue {
                            hasSeenIntro = true
                        }
                    }
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: introComplete)
        .onAppear {
            // If user has seen intro before, skip it
            if hasSeenIntro {
                introComplete = true
            }
            // Disable idle timer (no lock screen)
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .preferredColorScheme(settings.first?.isDarkMode == true ? .dark : .light)
    }
}
