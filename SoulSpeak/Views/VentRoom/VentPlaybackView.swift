import SwiftUI
import AVFoundation

/// Vent Room playback — plays back what the user recorded, then transitions to paper burn.
struct VentPlaybackView: View {
    @ObservedObject var recorder: VoiceRecorderService
    let onFinished: () -> Void

    @State private var isPlaying = false
    @State private var playbackProgress: CGFloat = 0
    @State private var player: AVAudioPlayer?

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.06)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.6))

                Text("Playing back your words...")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(.white)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0.9, green: 0.4, blue: 0.2))
                            .frame(width: geo.size.width * playbackProgress, height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 50)

                Text("Listen one last time before you let it go.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .italic()

                Spacer()

                // Skip playback button
                Button(action: onFinished) {
                    Text("Burn it now")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.2))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(Color(red: 0.9, green: 0.4, blue: 0.2).opacity(0.5), lineWidth: 1.5)
                        )
                }

                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard let url = recorder.recordingURL else {
            onFinished()
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            isPlaying = true

            // Animate progress
            let duration = player?.duration ?? 5.0
            withAnimation(.linear(duration: duration)) {
                playbackProgress = 1.0
            }

            // Auto-finish after playback
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
                onFinished()
            }
        } catch {
            print("[SoulSpeak] Playback error: \(error)")
            onFinished()
        }
    }
}
