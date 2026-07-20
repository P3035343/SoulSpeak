import SwiftUI
import SwiftData

/// Root content view — shows disclaimer first (one time), then intro sequence, then main app.
/// No lock screen; app goes straight to content.
struct ContentView: View {
    @AppStorage("hasAgreedToDisclaimerV2") private var hasAgreedToDisclaimer = false
    @AppStorage("hasSeenIntroV3") private var hasSeenIntro = false
    @State private var introComplete = false
    @Query private var settings: [UserSettings]

    var body: some View {
        ZStack {
            if !hasAgreedToDisclaimer {
                // FIRST: Legal disclaimer (must agree before anything)
                DisclaimerView(hasAgreed: $hasAgreedToDisclaimer)
                    .transition(.opacity)
            } else if !introComplete && !hasSeenIntro {
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
        .animation(.easeInOut(duration: 0.5), value: hasAgreedToDisclaimer)
        .animation(.easeInOut(duration: 0.5), value: introComplete)
        .onAppear {
            if hasSeenIntro {
                introComplete = true
            }
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .preferredColorScheme(settings.first?.isDarkMode == true ? .dark : .light)
    }
}
