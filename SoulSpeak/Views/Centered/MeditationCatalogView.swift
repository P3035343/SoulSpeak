import SwiftUI

/// Meditation Catalog — Scripted guided meditations by Dr. Hope and Mr. Hope.
/// User picks a session, audio plays with Dr. Hope or Mr. Hope guiding them.
///
/// Audio files expected:
/// - meditation_dr_hope_morning.mp3
/// - meditation_dr_hope_anxiety.mp3
/// - meditation_dr_hope_sleep.mp3
/// - meditation_dr_hope_grief.mp3
/// - meditation_dr_hope_gratitude.mp3
/// - meditation_mr_hope_energy.mp3
/// - meditation_mr_hope_confidence.mp3
/// - meditation_mr_hope_focus.mp3
/// - meditation_mr_hope_release.mp3
/// - meditation_mr_hope_motivation.mp3
struct MeditationCatalogView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @State private var currentlyPlaying: String? = nil
    @State private var selectedGuide: MeditationGuide = .drHope

    enum MeditationGuide: String, CaseIterable {
        case drHope = "Dr. Hope"
        case mrHope = "Mr. Hope"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.06, blue: 0.14),
                        Color(red: 0.12, green: 0.08, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Guide picker
                    guidePicker

                    // Sessions list
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(sessions(for: selectedGuide)) { session in
                                sessionCard(session)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Meditations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }


    // MARK: - Guide Picker
    private var guidePicker: some View {
        HStack(spacing: 16) {
            ForEach(MeditationGuide.allCases, id: \.self) { guide in
                Button(action: { selectedGuide = guide }) {
                    HStack(spacing: 8) {
                        Image(guide == .drHope ? "dr_hope" : "mr_hope")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())

                        Text(guide.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(selectedGuide == guide ? .white : .white.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(selectedGuide == guide
                                  ? (guide == .drHope ? Color(red: 0.7, green: 0.4, blue: 0.8).opacity(0.3) : Color(red: 0.3, green: 0.6, blue: 0.9).opacity(0.3))
                                  : Color.white.opacity(0.05))
                    )
                }
            }
        }
        .padding(.vertical, 16)
    }

    // MARK: - Session Card
    private func sessionCard(_ session: MeditationSession) -> some View {
        Button(action: { playSession(session) }) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(session.color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: session.icon)
                        .font(.system(size: 20))
                        .foregroundColor(session.color)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text(session.description)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)

                    Text(session.duration)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(session.color.opacity(0.8))
                }

                Spacer()

                // Play/pause
                Image(systemName: currentlyPlaying == session.fileName ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(currentlyPlaying == session.fileName ? session.color : .white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(currentlyPlaying == session.fileName ? session.color.opacity(0.06) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(currentlyPlaying == session.fileName ? session.color.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Play Session
    private func playSession(_ session: MeditationSession) {
        if currentlyPlaying == session.fileName {
            audioPlayer.stopAll()
            currentlyPlaying = nil
        } else {
            audioPlayer.stopAll()
            audioPlayer.playVoice(fileName: session.fileName)
            currentlyPlaying = session.fileName
        }
    }

    // MARK: - Sessions Data
    private func sessions(for guide: MeditationGuide) -> [MeditationSession] {
        switch guide {
        case .drHope:
            return [
                MeditationSession(name: "Morning Peace", fileName: "meditation_dr_hope_morning", description: "Start your day grounded in peace and gratitude", duration: "8 min", icon: "sunrise.fill", color: Color(red: 0.9, green: 0.7, blue: 0.3)),
                MeditationSession(name: "Ease Anxiety", fileName: "meditation_dr_hope_anxiety", description: "Breathe through the storm — find calm within", duration: "10 min", icon: "cloud.rain.fill", color: Color(red: 0.5, green: 0.7, blue: 0.9)),
                MeditationSession(name: "Sleep Well", fileName: "meditation_dr_hope_sleep", description: "Release the day and drift into restful sleep", duration: "15 min", icon: "moon.stars.fill", color: Color(red: 0.4, green: 0.3, blue: 0.7)),
                MeditationSession(name: "Healing Grief", fileName: "meditation_dr_hope_grief", description: "Honor your loss — let the ancestors hold you", duration: "12 min", icon: "heart.fill", color: Color(red: 0.8, green: 0.4, blue: 0.5)),
                MeditationSession(name: "Gratitude Practice", fileName: "meditation_dr_hope_gratitude", description: "Count your blessings and feel the abundance", duration: "7 min", icon: "sparkles", color: Color(red: 0.3, green: 0.7, blue: 0.5)),
            ]
        case .mrHope:
            return [
                MeditationSession(name: "Morning Energy", fileName: "meditation_mr_hope_energy", description: "Wake up fired up — today is YOUR day, Champ", duration: "6 min", icon: "bolt.fill", color: .orange),
                MeditationSession(name: "Build Confidence", fileName: "meditation_mr_hope_confidence", description: "Remind yourself who you are and what you're capable of", duration: "8 min", icon: "shield.fill", color: Color(red: 0.3, green: 0.6, blue: 0.9)),
                MeditationSession(name: "Laser Focus", fileName: "meditation_mr_hope_focus", description: "Lock in — block out the noise and execute", duration: "7 min", icon: "target", color: .red),
                MeditationSession(name: "Let It Go", fileName: "meditation_mr_hope_release", description: "Release what's weighing you down — travel light", duration: "9 min", icon: "wind", color: .teal),
                MeditationSession(name: "Get Motivated", fileName: "meditation_mr_hope_motivation", description: "The comeback is always stronger — let's go!", duration: "5 min", icon: "flame.fill", color: .yellow),
            ]
        }
    }
}

// MARK: - Meditation Session Model
struct MeditationSession: Identifiable {
    let id = UUID()
    let name: String
    let fileName: String
    let description: String
    let duration: String
    let icon: String
    let color: Color
}
