import SwiftUI
import AVFoundation

/// Voice Journal — Record, see waveform, get Dr. Hope's feedback
struct VoiceJournalScreen: View {
    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var showFeedback = false
    @State private var selectedMood: String?
    @State private var waveformLevels: [CGFloat] = Array(repeating: 0.1, count: 30)
    @State private var timer: Timer?
    @StateObject private var audioPlayer = AudioPlayerService.shared

    private let moods = ["😊", "😌", "😢", "😰", "😡", "🙏", "⚡", "🌟"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Dr. Hope office background
                Image("dr_hope_office")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.4))

                // Fallback
                SSColors.background.ignoresSafeArea().opacity(0.3)

                ScrollView {
                    VStack(spacing: 24) {
                        // Dr. Hope avatar + feedback area
                        drHopeSection

                        // Waveform
                        waveformView

                        // Record controls
                        recordControls

                        // Mood selector
                        moodSelector

                        // Dr. Hope's text feedback
                        if showFeedback {
                            feedbackSection
                        }
                    }
                    .padding()
                    .padding(.top, 40)
                }
            }
            .navigationTitle("Voice Journal")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            audioPlayer.playBackgroundMusic(fileName: "jazz_loop_1")
        }
        .onDisappear {
            audioPlayer.stopBackgroundMusic()
        }
    }

    // MARK: - Dr. Hope Section
    private var drHopeSection: some View {
        HStack(spacing: 16) {
            // Dr. Hope avatar
            Image("dr_hope")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(SSColors.primary.opacity(0.5), lineWidth: 2))

            VStack(alignment: .leading, spacing: 4) {
                Text("Dr. Hope")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(isRecording ? "I'm listening, take your time..." : "Tell me what's on your heart today.")
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Waveform
    private var waveformView: some View {
        HStack(spacing: 3) {
            ForEach(0..<30, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isRecording ? SSColors.primary : Color.gray.opacity(0.3))
                    .frame(width: 4, height: waveformLevels[index] * 50)
                    .animation(.easeInOut(duration: 0.1), value: waveformLevels[index])
            }
        }
        .frame(height: 60)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Record Controls
    private var recordControls: some View {
        VStack(spacing: 12) {
            // Duration
            Text(formatDuration(recordingDuration))
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.white)

            // Record/Stop button
            Button(action: toggleRecording) {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color.red : SSColors.primary)
                        .frame(width: 72, height: 72)
                        .shadow(color: (isRecording ? Color.red : SSColors.primary).opacity(0.5), radius: 10, y: 4)

                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .frame(width: 24, height: 24)
                    } else {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)
                    }
                }
            }

            Text(isRecording ? "Tap to stop" : "Tap to record")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Mood Selector
    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How are you feeling?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 12) {
                ForEach(moods, id: \.self) { mood in
                    Button(action: { selectedMood = mood }) {
                        Text(mood)
                            .font(.system(size: 28))
                            .padding(6)
                            .background(
                                Circle().fill(selectedMood == mood ? SSColors.primary.opacity(0.3) : Color.clear)
                            )
                            .overlay(
                                Circle().stroke(selectedMood == mood ? SSColors.primary : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Feedback
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image("dr_hope")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                Text("Dr. Hope's Reflection")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text("I hear you, and I want you to know that your feelings are valid. Taking time to express yourself like this shows real strength. Remember — you don't have to carry everything alone.")
                .font(.system(size: 15, design: .serif))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Actions
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        recordingDuration = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
            // Simulate waveform
            for i in 0..<waveformLevels.count {
                waveformLevels[i] = CGFloat.random(in: 0.1...1.0)
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        waveformLevels = Array(repeating: 0.1, count: 30)

        // Show Dr. Hope's feedback after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.4)) {
                showFeedback = true
            }
            // Play Dr. Hope's voice response
            audioPlayer.playVoice(fileName: "dr_hope_intro")
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
