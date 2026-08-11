import SwiftUI
import SwiftData

/// Root content view — shows disclaimer FIRST (mandatory, cannot bypass).
/// After agreement: intro sequence (one time), then main hub.
///
/// Flow:
/// 1. DisclaimerView — blocks EVERYTHING until both checkboxes checked
/// 2. IntroSequenceView — plays once (Mr. Hope greeting, office walkthrough)
/// 3. MainHubView — the main app experience
///
/// Persistence:
/// - hasAgreedToDisclaimerV2: once true, disclaimer never shows again
/// - hasSeenIntroV3: once true, intro sequence is skipped
struct ContentView: View {
    @State private var hasAgreedToDisclaimer = false
    @AppStorage("hasSeenIntroV3") private var hasSeenIntro = false
    @State private var introComplete = false
    @Query private var settings: [UserSettings]

    var body: some View {
        ZStack {
            // Main content (behind disclaimer if not agreed)
            if hasAgreedToDisclaimer {
                if !introComplete && !hasSeenIntro {
                    IntroSequenceView(introComplete: $introComplete)
                        .transition(.opacity)
                        .onChange(of: introComplete) { _, newValue in
                            if newValue {
                                hasSeenIntro = true
                            }
                        }
                } else {
                    MainHubView()
                        .transition(.opacity)
                }
            }

            // Disclaimer overlay — BLOCKS EVERYTHING if not agreed
            // This is a ZStack overlay so it sits on TOP and cannot be dismissed
            if !hasAgreedToDisclaimer {
                DisclaimerView(hasAgreed: $hasAgreedToDisclaimer)
                    .transition(.opacity)
                    .zIndex(999) // Always on top
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
