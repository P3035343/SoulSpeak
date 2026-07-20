import SwiftUI

/// Vent Room — Premium feature for emotional release.
///
/// Flow:
/// 1. Mr. Hope intro video (presents the room, opens the door)
/// 2. Room with recording → playback → paper → fireplace
/// 3. Interactive destruction tools (break, throw, smash, spray)
/// 4. "Release" button resets the room
///
/// Video expected: mr_hope_vent_room.mp4
enum VentRoomPhase {
    case intro          // Mr. Hope video presenting the room
    case recording      // User records their vent
    case playback       // Playing back what they said
    case paperBurn      // Recording transforms to paper → fireplace
    case destruction    // Interactive room destruction
    case release        // Release button → room resets
}

struct VentRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recorder = VoiceRecorderService()
    @StateObject private var store = StoreKitService.shared

    @State private var phase: VentRoomPhase = .intro
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !store.isPremium {
                // Show paywall if not premium
                lockedView
            } else {
                switch phase {
                case .intro:
                    ventRoomIntro

                case .recording:
                    VentRecordingView(
                        recorder: recorder,
                        onFinished: {
                            withAnimation { phase = .playback }
                        }
                    )

                case .playback:
                    VentPlaybackView(
                        recorder: recorder,
                        onFinished: {
                            withAnimation(.easeInOut(duration: 0.5)) { phase = .paperBurn }
                        }
                    )

                case .paperBurn:
                    PaperBurnView(
                        onFinished: {
                            withAnimation(.easeInOut(duration: 0.5)) { phase = .destruction }
                        }
                    )

                case .destruction:
                    DestructionRoomView(
                        onRelease: {
                            withAnimation(.easeInOut(duration: 0.8)) { phase = .release }
                        }
                    )

                case .release:
                    ReleaseView(
                        onComplete: {
                            withAnimation { phase = .recording }
                        },
                        onExit: { dismiss() }
                    )
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Locked View (not premium)
    private var lockedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.2))

            Text("The Vent Room")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("A safe space to release your frustration.\nRecord. Burn. Destroy. Let go.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button(action: { showPaywall = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(Color(red: 0.95, green: 0.78, blue: 0.3))
                    Text("Unlock Premium")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 36)
                .background(
                    Capsule()
                        .fill(SSColors.gradientPrimary)
                )
            }

            Spacer()

            Button(action: { dismiss() }) {
                Text("Go Back")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Mr. Hope Intro Video
    private var ventRoomIntro: some View {
        ZStack {
            FullScreenVideoBackground(
                videoName: "mr_hope_vent_room",
                fileExtension: "mp4",
                looping: false,
                onFinished: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        phase = .recording
                    }
                }
            )
        }
    }
}
