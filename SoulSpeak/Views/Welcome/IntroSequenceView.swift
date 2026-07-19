import SwiftUI

/// Cinematic intro sequence — first-person office experience.
///
/// Flow:
/// 1. Office door with wooden doorknob (user taps to enter)
/// 2. mr_hope_intro.mp4 — One continuous shot: entering office, Mr. Hope greets,
///    leads user to Dr. Hope's office, explains she's his wife
/// 3. dr_hope_intro.mp4 — Dr. Hope introduces herself (auto-starts after Mr. Hope)
/// 4. → Main app begins
///
/// All videos have voice/script baked in — no text overlays needed.
/// No skip button — full immersive experience.
///
/// Video files expected in bundle:
/// - mr_hope_intro.mp4    (one combined shot: enter office, greeting, walkthrough)
/// - dr_hope_intro.mp4    (Dr. Hope introduces herself)

enum IntroPhase {
    case door
    case mrHopeIntro       // Combined Mr. Hope video
    case drHopeIntro       // Dr. Hope introduces herself
    case complete
}

struct IntroSequenceView: View {
    @Binding var introComplete: Bool

    @State private var phase: IntroPhase = .door
    @State private var doorKnobScale: CGFloat = 1.0
    @State private var doorKnobGlow = false
    @State private var doorOpening = false
    @State private var screenFade: Double = 1.0
    @State private var showTapHint = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch phase {
            case .door:
                doorScreen
                    .opacity(screenFade)

            case .mrHopeIntro:
                videoPhase(
                    videoName: "mr_hope_intro",
                    onFinished: { advanceTo(.drHopeIntro) }
                )

            case .drHopeIntro:
                videoPhase(
                    videoName: "dr_hope_intro",
                    onFinished: { advanceTo(.complete) }
                )

            case .complete:
                Color.clear
            }
        }
    }

    // MARK: - Door Screen
    private var doorScreen: some View {
        ZStack {
            // Dark hallway background
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.04, blue: 0.1),
                    Color(red: 0.12, green: 0.08, blue: 0.16),
                    Color(red: 0.08, green: 0.05, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Warm light leaking from under the door
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: 120)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                Spacer()

                // Door frame
                ZStack {
                    // The door itself
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.35, green: 0.22, blue: 0.12),
                                    Color(red: 0.28, green: 0.17, blue: 0.08),
                                    Color(red: 0.32, green: 0.2, blue: 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 360)
                        .overlay(
                            // Wood grain texture lines
                            VStack(spacing: 18) {
                                ForEach(0..<15, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color.black.opacity(0.06))
                                        .frame(height: 1)
                                }
                            }
                            .padding(.vertical, 20)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.25, green: 0.15, blue: 0.08), lineWidth: 4)
                        )
                        .shadow(color: Color.black.opacity(0.5), radius: 20, y: 10)
                        .scaleEffect(doorOpening ? 0.9 : 1.0)
                        .opacity(doorOpening ? 0.0 : 1.0)
                        .allowsHitTesting(false)

                    // THE DOORKNOB — tap target (entire door is tappable)
                    Button(action: openDoor) {
                        ZStack {
                            // Invisible large tap target covering the door
                            Color.clear
                                .frame(width: 220, height: 360)

                            // Glow behind knob
                            Circle()
                                .fill(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(doorKnobGlow ? 0.4 : 0.15))
                                .frame(width: 70, height: 70)
                                .scaleEffect(doorKnobGlow ? 1.2 : 1.0)

                            // The knob — beautiful golden/brass
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.95, green: 0.82, blue: 0.4),
                                            Color(red: 0.8, green: 0.6, blue: 0.2),
                                            Color(red: 0.6, green: 0.4, blue: 0.1)
                                        ],
                                        center: .init(x: 0.35, y: 0.35),
                                        startRadius: 2,
                                        endRadius: 25
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0.7, green: 0.5, blue: 0.15), lineWidth: 2)
                                )
                                .shadow(color: Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.5), radius: 8, y: 2)

                            // Keyhole detail
                            Capsule()
                                .fill(Color(red: 0.3, green: 0.2, blue: 0.08))
                                .frame(width: 4, height: 12)
                                .offset(y: 2)
                        }
                        .scaleEffect(doorKnobScale)
                    }
                    .buttonStyle(.plain)
                    .opacity(doorOpening ? 0.0 : 1.0)
                }

                Spacer()
                    .frame(height: 80)

                // "Tap to enter" hint
                if showTapHint && !doorOpening {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3).opacity(0.7))

                        Text("Touch the doorknob to enter")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .transition(.opacity)
                }

                Spacer()
                    .frame(height: 60)
            }
        }
        .onAppear {
            startDoorAnimations()
        }
    }

    // MARK: - Video Phase
    private func videoPhase(videoName: String, onFinished: @escaping () -> Void) -> some View {
        FullScreenVideoBackground(
            videoName: videoName,
            fileExtension: "mp4",
            looping: false,
            onFinished: onFinished
        )
        .transition(.opacity)
    }

    // MARK: - Animations
    private func startDoorAnimations() {
        // Doorknob glow pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            doorKnobGlow = true
        }

        // Doorknob subtle scale pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            doorKnobScale = 1.08
        }

        // Show tap hint after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeIn(duration: 0.5)) {
                showTapHint = true
            }
        }
    }

    // MARK: - Actions
    private func openDoor() {
        // Door opening animation
        withAnimation(.easeInOut(duration: 0.6)) {
            doorOpening = true
            showTapHint = false
        }

        // Fade to black
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) {
                screenFade = 0
            }
        }

        // Start Mr. Hope's video
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            phase = .mrHopeIntro
            screenFade = 1.0
        }
    }

    private func advanceTo(_ nextPhase: IntroPhase) {
        if nextPhase == .complete {
            withAnimation(.easeInOut(duration: 0.5)) {
                introComplete = true
            }
        } else {
            // Brief fade between videos
            withAnimation(.easeOut(duration: 0.3)) {
                screenFade = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                phase = nextPhase
                withAnimation(.easeIn(duration: 0.3)) {
                    screenFade = 1.0
                }
            }
        }
    }
}
