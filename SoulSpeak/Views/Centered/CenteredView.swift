import SwiftUI

/// Centered — A peaceful interactive office session space.
///
/// Features:
/// - Walking intro video (entering the Centered room)
/// - Soundscapes & relaxation music playlist (free)
/// - Ethiopian Bible audio (free, clickable chapters)
/// - Meditation session catalog (scripted by Mr. Hope & Dr. Hope)
/// - Interactive office atmosphere
///
/// Video expected: centered_room_intro.mp4
enum CenteredSection: String, CaseIterable, Identifiable {
    case soundscapes = "Soundscapes"
    case bible = "Ethiopian Bible"
    case meditations = "Meditations"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .soundscapes: return "waveform.circle.fill"
        case .bible: return "book.fill"
        case .meditations: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .soundscapes: return Color(red: 0.4, green: 0.7, blue: 0.9)
        case .bible: return Color(red: 0.85, green: 0.7, blue: 0.3)
        case .meditations: return Color(red: 0.7, green: 0.4, blue: 0.8)
        }
    }
}

struct CenteredView: View {
    @State private var showIntroVideo = true
    @State private var selectedSection: CenteredSection? = nil
    @State private var breatheAnimation = false

    var body: some View {
        ZStack {
            if showIntroVideo {
                // Walking intro video
                centeredIntroVideo
            } else {
                // Main Centered room
                centeredMainView
            }
        }
        .navigationTitle(showIntroVideo ? "" : "Centered")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Intro Video
    private var centeredIntroVideo: some View {
        FullScreenVideoBackground(
            videoName: "centered_room_intro",
            fileExtension: "mp4",
            looping: false,
            onFinished: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showIntroVideo = false
                }
            }
        )
    }

    // MARK: - Main View
    private var centeredMainView: some View {
        ZStack {
            // Peaceful office background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.1, blue: 0.14),
                    Color(red: 0.12, green: 0.14, blue: 0.2),
                    Color(red: 0.06, green: 0.08, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow
            RadialGradient(
                colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8).opacity(breatheAnimation ? 0.08 : 0.04),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                        .padding(.top, 20)

                    // Section cards
                    ForEach(CenteredSection.allCases) { section in
                        sectionCard(section)
                    }

                    // Now Playing mini player (if something is playing)
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breatheAnimation = true
            }
        }
        .sheet(item: $selectedSection) { section in
            switch section {
            case .soundscapes:
                SoundscapesView()
            case .bible:
                EthiopianBibleView()
            case .meditations:
                MeditationCatalogView()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Lotus/peace icon
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 44))
                .foregroundColor(Color(red: 0.4, green: 0.7, blue: 0.9))
                .scaleEffect(breatheAnimation ? 1.05 : 1.0)

            Text("Find Your Center")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Text("Breathe. Listen. Be still.")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(.white.opacity(0.6))
                .italic()
        }
    }

    // MARK: - Section Card
    private func sectionCard(_ section: CenteredSection) -> some View {
        Button(action: { selectedSection = section }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(section.color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: section.icon)
                        .font(.system(size: 24))
                        .foregroundColor(section.color)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Text(sectionDescription(section))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(section.color.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    private func sectionDescription(_ section: CenteredSection) -> String {
        switch section {
        case .soundscapes:
            return "Free relaxing soundscapes, nature sounds, and instrumental music"
        case .bible:
            return "Listen to the Ethiopian Bible — free audio chapters"
        case .meditations:
            return "Guided meditations from Dr. Hope & Mr. Hope"
        }
    }
}
