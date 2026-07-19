import SwiftUI

/// The full intro sequence that plays when the user first opens the app:
/// 1. Mr. Hope video intro (he greets the user, introduces Dr. Hope)
/// 2. Transition
/// 3. Dr. Hope video intro (she introduces herself)
/// 4. User enters the main app
///
/// Video files expected:
/// - mr_hope_intro_video.mp4
/// - dr_hope_intro_video.mp4
enum IntroPhase {
    case mrHopeIntro
    case transition
    case drHopeIntro
    case ready
}

struct IntroSequenceView: View {
    @Binding var introComplete: Bool
    @State private var phase: IntroPhase = .mrHopeIntro
    @State private var fadeOpacity: Double = 1.0
    @State private var transitionOpacity: Double = 0
    @State private var showSkipButton = false
    @State private var subtitleText: String = ""
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background (always black during transitions)
            Color.black.ignoresSafeArea()

            switch phase {
            case .mrHopeIntro:
                mrHopeIntroScreen
                    .opacity(fadeOpacity)

            case .transition:
                transitionScreen
                    .opacity(transitionOpacity)

            case .drHopeIntro:
                drHopeIntroScreen
                    .opacity(fadeOpacity)

            case .ready:
                readyScreen
            }

            // Skip button (always available after 2 seconds)
            if showSkipButton && phase != .ready {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: skipToApp) {
                            Text("Skip")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.15))
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            // Show skip button after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { showSkipButton = true }
            }
        }
    }

    // MARK: - Mr. Hope Intro Screen
    private var mrHopeIntroScreen: some View {
        ZStack {
            // Video plays full screen
            FullScreenVideoBackground(
                videoName: "mr_hope_intro_video",
                fileExtension: "mp4",
                looping: false,
                onFinished: { transitionToNextPhase() }
            )

            // Subtitle overlay at bottom
            VStack {
                Spacer()

                // Character name tag
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(red: 0.3, green: 0.6, blue: 0.9))
                        .frame(width: 10, height: 10)
                    Text("Mr. Hope")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.5))
                )
                .padding(.bottom, 8)

                // Subtitle text
                Text("\"Hey there, Champ! Welcome to SoulSpeak.\nDr. Hope is ready for you...\"")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(.bottom, 50)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            // Fade in subtitle after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.6)) {
                    subtitleOpacity = 1.0
                }
            }
        }
    }

    // MARK: - Transition Screen
    private var transitionScreen: some View {
        VStack(spacing: 20) {
            // Elegant transition with sparkle
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(Color(red: 0.9, green: 0.7, blue: 0.3))

            Text("Dr. Hope will see you now...")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(.white.opacity(0.9))
                .italic()
        }
    }

    // MARK: - Dr. Hope Intro Screen
    private var drHopeIntroScreen: some View {
        ZStack {
            // Video plays full screen
            FullScreenVideoBackground(
                videoName: "dr_hope_intro_video",
                fileExtension: "mp4",
                looping: false,
                onFinished: { finishIntro() }
            )

            // Subtitle overlay at bottom
            VStack {
                Spacer()

                // Character name tag
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(red: 0.7, green: 0.4, blue: 0.8))
                        .frame(width: 10, height: 10)
                    Text("Dr. Hope")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.5))
                )
                .padding(.bottom, 8)

                // Subtitle text
                Text("\"Welcome, baby. I'm Dr. Hope.\nThis is a safe space. Let's talk.\"")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6))
                    )
                    .padding(.bottom, 50)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            subtitleOpacity = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.6)) {
                    subtitleOpacity = 1.0
                }
            }
        }
    }

    // MARK: - Ready Screen (brief before entering app)
    private var readyScreen: some View {
        ZStack {
            // Dark warm background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color(red: 0.08, green: 0.06, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Both character indicators
                HStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0.3, green: 0.6, blue: 0.9).opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "hand.wave.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.9))
                            )
                        Text("Mr. Hope")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0.7, green: 0.4, blue: 0.8).opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(red: 0.7, green: 0.4, blue: 0.8))
                            )
                        Text("Dr. Hope")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Text("Your session is ready")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("Take a deep breath. You're in good hands.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        introComplete = true
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                        Text("Begin Session")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 48)
                    .background(
                        Capsule()
                            .fill(SSColors.gradientPrimary)
                            .shadow(color: SSColors.primary.opacity(0.5), radius: 12, y: 6)
                    )
                }
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Actions
    private func transitionToNextPhase() {
        // Fade out Mr. Hope
        withAnimation(.easeOut(duration: 0.5)) {
            fadeOpacity = 0
        }

        // Show transition text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            phase = .transition
            withAnimation(.easeIn(duration: 0.8)) {
                transitionOpacity = 1.0
            }
        }

        // Move to Dr. Hope after transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                transitionOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                phase = .drHopeIntro
                fadeOpacity = 0
                withAnimation(.easeIn(duration: 0.5)) {
                    fadeOpacity = 1.0
                }
            }
        }
    }

    private func finishIntro() {
        withAnimation(.easeOut(duration: 0.5)) {
            fadeOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeIn(duration: 0.5)) {
                phase = .ready
            }
        }
    }

    private func skipToApp() {
        withAnimation(.easeInOut(duration: 0.3)) {
            introComplete = true
        }
    }
}
