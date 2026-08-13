import SwiftUI
import SwiftData
import CoreLocation
import UserNotifications
import AVFAudio

/// Root content view — shows disclaimer FIRST (mandatory, cannot bypass).
/// After agreement: requests permissions, then intro sequence, then main hub.
///
/// Flow:
/// 1. DisclaimerView — blocks EVERYTHING until both checkboxes checked
/// 2. Permission requests (location, notifications)
/// 3. IntroSequenceView — plays once (Mr. Hope greeting, office walkthrough)
/// 4. MainHubView — the main app experience
struct ContentView: View {
    @State private var hasAgreedToDisclaimer = false
    @AppStorage("hasSeenIntroV3") private var hasSeenIntro = false
    @State private var introComplete = false
    @State private var permissionsRequested = false
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
            if !hasAgreedToDisclaimer {
                DisclaimerView(hasAgreed: $hasAgreedToDisclaimer)
                    .transition(.opacity)
                    .zIndex(999)
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
        .onChange(of: hasAgreedToDisclaimer) { _, agreed in
            if agreed && !permissionsRequested {
                permissionsRequested = true
                requestAllPermissions()
            }
        }
        .preferredColorScheme(settings.first?.isDarkMode == true ? .dark : .light)
    }

    // MARK: - Request All Permissions
    private func requestAllPermissions() {
        // 1. Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("[SoulSpeak] Notifications permission: \(granted)")
        }

        // 2. Location (for Emergency feature + resource finder)
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        print("[SoulSpeak] Location permission requested")

        // 3. Microphone (for voice journal + speech recognition)
        AVAudioApplication.requestRecordPermission { granted in
            print("[SoulSpeak] Microphone permission: \(granted)")
        }
    }
}
