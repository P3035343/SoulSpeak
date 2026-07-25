import SwiftUI

/// Meditation Catalog — Pre-recorded guided meditation sessions.
/// Audio files are already recorded with Dr. Hope and Mr. Hope voices.
struct MeditationCatalogView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @State private var currentlyPlaying: String? = nil

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

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(sessions) { session in
                            sessionCard(session)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
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

    // MARK: - Session Card
    private func sessionCard(_ session: MeditationSession) -> some View {
        Button(action: { playSession(session) }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(session.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: session.icon)
                        .font(.system(size: 20))
                        .foregroundColor(session.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(session.guide)
                        .font(.system(size: 11))
                        .foregroundColor(session.color.opacity(0.8))
                }

                Spacer()

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

    // MARK: - Play
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

    // MARK: - Sessions (matches your actual MP3 files)
    private var sessions: [MeditationSession] {
        [
            MeditationSession(
                name: "Cooling the Fire",
                fileName: "anger_management_meditation",
                guide: "Anger Management",
                icon: "flame.fill",
                color: .red
            ),
            MeditationSession(
                name: "Breaking Free",
                fileName: "breaking_free_abusive_relationship",
                guide: "Abusive Relationship Recovery",
                icon: "link.badge.plus",
                color: Color(red: 0.8, green: 0.4, blue: 0.5)
            ),
            MeditationSession(
                name: "Feminine Energy Pep Talk",
                fileName: "feminine_energy_pep_talk",
                guide: "Empowerment",
                icon: "sparkles",
                color: Color(red: 0.9, green: 0.5, blue: 0.7)
            ),
            MeditationSession(
                name: "The Quiet Place Within",
                fileName: "inner_peace_meditation",
                guide: "Inner Peace",
                icon: "leaf.fill",
                color: Color(red: 0.3, green: 0.7, blue: 0.5)
            ),
            MeditationSession(
                name: "Making Peace Within",
                fileName: "internal_conflict_meditation",
                guide: "Internal Conflict",
                icon: "arrow.triangle.branch",
                color: Color(red: 0.5, green: 0.5, blue: 0.8)
            ),
            MeditationSession(
                name: "Strength With Purpose",
                fileName: "masculine_energy_pep_talk",
                guide: "Masculine Energy",
                icon: "shield.fill",
                color: Color(red: 0.3, green: 0.5, blue: 0.9)
            ),
            MeditationSession(
                name: "Reclaiming Your Heart",
                fileName: "overcoming_harmful_relationship",
                guide: "Harmful Relationship Recovery",
                icon: "heart.fill",
                color: Color(red: 0.7, green: 0.3, blue: 0.4)
            ),
            MeditationSession(
                name: "Restoring Your Energy",
                fileName: "rejuvenation_meditation_dh",
                guide: "Dr. Hope",
                icon: "bolt.heart.fill",
                color: Color(red: 0.7, green: 0.4, blue: 0.8)
            ),
            MeditationSession(
                name: "Restoring Your Energy",
                fileName: "rejuvenation_meditation_mh",
                guide: "Mr. Hope",
                icon: "bolt.heart.fill",
                color: Color(red: 0.3, green: 0.6, blue: 0.9)
            ),
            MeditationSession(
                name: "Returning Love to Yourself",
                fileName: "returning_love_to_yourself",
                guide: "Self-Love",
                icon: "heart.circle.fill",
                color: Color(red: 0.9, green: 0.6, blue: 0.4)
            ),
            MeditationSession(
                name: "Lay the Weight Down",
                fileName: "stress_release_meditation",
                guide: "Stress Release",
                icon: "cloud.rain.fill",
                color: Color(red: 0.4, green: 0.6, blue: 0.8)
            ),
        ]
    }
}

struct MeditationSession: Identifiable {
    let id = UUID()
    let name: String
    let fileName: String
    let guide: String
    let icon: String
    let color: Color
}
