import SwiftUI

/// Soundscapes — Free playlist of relaxing soundscapes and instrumental music.
///
/// Audio files expected in bundle (all free/royalty-free):
/// - rain_gentle.mp3
/// - ocean_waves.mp3
/// - forest_birds.mp3
/// - creek_flowing.mp3
/// - thunder_distant.mp3
/// - night_crickets.mp3
/// - piano_calm.mp3
/// - guitar_acoustic.mp3
/// - flute_meditation.mp3
/// - jazz_soft.mp3
/// - harp_peaceful.mp3
/// - chimes_wind.mp3
struct SoundscapesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioPlayer = AudioPlayerService.shared
    @State private var currentlyPlaying: String? = nil
    @State private var selectedCategory: SoundCategory = .nature

    enum SoundCategory: String, CaseIterable {
        case nature = "Nature"
        case instrumental = "Instrumental"
        case ambient = "Ambient"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.1, blue: 0.16),
                        Color(red: 0.08, green: 0.12, blue: 0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(SoundCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Track list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(tracks(for: selectedCategory)) { track in
                                trackRow(track)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }

                    // Now playing bar
                    if currentlyPlaying != nil {
                        nowPlayingBar
                    }
                }
            }
            .navigationTitle("Soundscapes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    // MARK: - Track Row
    private func trackRow(_ track: SoundTrack) -> some View {
        Button(action: { playTrack(track) }) {
            HStack(spacing: 14) {
                // Play/pause icon
                ZStack {
                    Circle()
                        .fill(currentlyPlaying == track.fileName ? track.color.opacity(0.2) : Color.white.opacity(0.06))
                        .frame(width: 48, height: 48)

                    Image(systemName: currentlyPlaying == track.fileName ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(currentlyPlaying == track.fileName ? track.color : .white.opacity(0.6))
                }

                // Track info
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)

                    Text(track.duration)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Loop indicator
                Image(systemName: "repeat")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(currentlyPlaying == track.fileName ? track.color.opacity(0.08) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(currentlyPlaying == track.fileName ? track.color.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Now Playing Bar
    private var nowPlayingBar: some View {
        HStack(spacing: 12) {
            // Animated bars
            HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.4, green: 0.7, blue: 0.9))
                        .frame(width: 3, height: CGFloat.random(in: 8...18))
                }
            }

            Text("Now Playing")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Button(action: stopPlaying) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.8))
    }

    // MARK: - Actions
    private func playTrack(_ track: SoundTrack) {
        if currentlyPlaying == track.fileName {
            stopPlaying()
        } else {
            audioPlayer.stopAll()
            audioPlayer.playBackgroundMusic(fileName: track.fileName)
            currentlyPlaying = track.fileName
        }
    }

    private func stopPlaying() {
        audioPlayer.stopAll()
        currentlyPlaying = nil
    }

    // MARK: - Track Data
    private func tracks(for category: SoundCategory) -> [SoundTrack] {
        switch category {
        case .nature:
            return [
                SoundTrack(name: "Gentle Rain", fileName: "rain_gentle", duration: "Loop", color: .blue),
                SoundTrack(name: "Ocean Waves", fileName: "ocean_waves", duration: "Loop", color: .cyan),
                SoundTrack(name: "Forest Birds", fileName: "forest_birds", duration: "Loop", color: .green),
                SoundTrack(name: "Flowing Creek", fileName: "creek_flowing", duration: "Loop", color: .teal),
                SoundTrack(name: "Distant Thunder", fileName: "thunder_distant", duration: "Loop", color: .purple),
                SoundTrack(name: "Night Crickets", fileName: "night_crickets", duration: "Loop", color: .indigo),
            ]
        case .instrumental:
            return [
                SoundTrack(name: "Calm Piano", fileName: "piano_calm", duration: "Loop", color: .white),
                SoundTrack(name: "Acoustic Guitar", fileName: "guitar_acoustic", duration: "Loop", color: .orange),
                SoundTrack(name: "Meditation Flute", fileName: "flute_meditation", duration: "Loop", color: .mint),
                SoundTrack(name: "Soft Jazz", fileName: "jazz_soft", duration: "Loop", color: .yellow),
                SoundTrack(name: "Peaceful Harp", fileName: "harp_peaceful", duration: "Loop", color: .pink),
            ]
        case .ambient:
            return [
                SoundTrack(name: "Wind Chimes", fileName: "chimes_wind", duration: "Loop", color: .cyan),
                SoundTrack(name: "Singing Bowls", fileName: "singing_bowls", duration: "Loop", color: .purple),
                SoundTrack(name: "Fireplace Crackle", fileName: "fireplace_crackle", duration: "Loop", color: .orange),
                SoundTrack(name: "Cafe Ambience", fileName: "cafe_ambience", duration: "Loop", color: .brown),
            ]
        }
    }
}

struct SoundTrack: Identifiable {
    let id = UUID()
    let name: String
    let fileName: String
    let duration: String
    let color: Color
}
