import SwiftUI
import SwiftData

/// Voice Journal Screen: Record/Stop, waveform animation, Dr. Hope's text feedback, mood selector.
/// Dr. Hope is Gullah-style, comforting, wise.
struct VoiceJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var recorder = VoiceRecorderService()
    @StateObject private var audioPlayer = AudioPlayerService.shared

    @State private var selectedMood: Mood?
    @State private var drHopeFeedback: String = ""
    @State private var showFeedback = false
    @State private var showMoodSelector = false
    @State private var drHopeTalking = false
    @State private var mouthPulse: CGFloat = 1.0
    @State private var savedEntry = false

    var body: some View {
        ZStack {
            // Office background
            Image("dr_hope_office_render")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.5).ignoresSafeArea())

            ScrollView {
                VStack(spacing: 28) {
                    // Dr. Hope avatar section
                    drHopeSection
                        .padding(.top, 20)

                    // Waveform
                    waveformSection

                    // Record button
                    recordButton

                    // Dr. Hope feedback (appears after recording)
                    if showFeedback {
                        feedbackCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Mood selector (appears after feedback)
                    if showMoodSelector {
                        moodSelectorSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Save confirmation
                    if savedEntry {
                        savedConfirmation
                            .transition(.scale.combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Voice Journal")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Dr. Hope Avatar
    private var drHopeSection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Glow
                Circle()
                    .fill(Color(red: 0.7, green: 0.4, blue: 0.8).opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(drHopeTalking ? 1.15 : 1.0)

                // Avatar
                Image("dr_hope")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.7, green: 0.4, blue: 0.8), lineWidth: 2)
                    )
                    .shadow(color: Color(red: 0.7, green: 0.4, blue: 0.8).opacity(0.4), radius: 8)
                    .scaleEffect(drHopeTalking ? mouthPulse : 1.0)

                // Talking indicator
                if drHopeTalking {
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color(red: 0.7, green: 0.4, blue: 0.8))
                                .frame(width: 3, height: CGFloat(6 + i * 3) * mouthPulse)
                        }
                    }
                    .offset(x: 45, y: 5)
                }
            }

            Text("Dr. Hope")
                .font(SSTypography.caption)
                .foregroundColor(.white.opacity(0.8))

            if !recorder.isRecording && !showFeedback {
                Text("\"Go on, baby. Speak your truth.\nI'm right here listenin'.\"")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .italic()
            }
        }
    }

    // MARK: - Waveform Section
    private var waveformSection: some View {
        VStack(spacing: 12) {
            if recorder.isRecording {
                WaveformView(levels: recorder.audioLevels, isActive: true)
            } else {
                IdleWaveformView()
            }

            // Duration display
            Text(recorder.isRecording ? recorder.formattedDuration : "Ready to record")
                .font(SSTypography.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Record Button
    private var recordButton: some View {
        Button(action: toggleRecording) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                    .frame(width: 80, height: 80)

                // Animated recording ring
                if recorder.isRecording {
                    Circle()
                        .stroke(Color.red.opacity(0.6), lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .scaleEffect(recorder.isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: recorder.isRecording)
                }

                // Inner button
                if recorder.isRecording {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red)
                        .frame(width: 28, height: 28)
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 56, height: 56)
                }
            }
        }

        Text(recorder.isRecording ? "Tap to Stop" : "Tap to Record")
            .font(SSTypography.caption)
            .foregroundColor(.white.opacity(0.6))
    }

    // MARK: - Feedback Card
    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image("dr_hope")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                Text("Dr. Hope's Reflection")
                    .font(SSTypography.caption)
                    .foregroundColor(SSColors.textSecondary)
            }

            Text(drHopeFeedback)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundColor(SSColors.textPrimary)
                .italic()
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.92))
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        )
    }

    // MARK: - Mood Selector
    private var moodSelectorSection: some View {
        VStack(spacing: 16) {
            Text("How are you feeling now?")
                .font(SSTypography.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 14) {
                ForEach(Mood.allCases) { mood in
                    moodButton(mood)
                }
            }

            if selectedMood != nil {
                Button(action: saveJournalEntry) {
                    Text("Save Journal Entry")
                        .font(SSTypography.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 32)
                        .background(
                            Capsule()
                                .fill(SSColors.gradientPrimary)
                        )
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func moodButton(_ mood: Mood) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMood = mood
            }
        }) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                Text(mood.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(selectedMood == mood ? .white : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedMood == mood ? mood.color.opacity(0.6) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 2)
            )
        }
    }

    // MARK: - Saved Confirmation
    private var savedConfirmation: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(SSColors.success)
            Text("Journal entry saved")
                .font(SSTypography.body)
                .foregroundColor(.white)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(SSColors.success.opacity(0.2))
        )
    }

    // MARK: - Actions
    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
            generateDrHopeFeedback()
        } else {
            savedEntry = false
            showFeedback = false
            showMoodSelector = false
            selectedMood = nil
            recorder.startRecording()
            // Play Dr. Hope intro when starting
            audioPlayer.playVoice(fileName: "dr_hope_intro")
        }
    }

    private func generateDrHopeFeedback() {
        // Simulate Dr. Hope's Gullah-style feedback based on duration
        let duration = recorder.recordingDuration

        let feedbacks = [
            "Mmhmm, I hear you, baby. That took courage to let out. The swamp don't clear itself — you gotta wade through. And you wadin'. I'm proud of you.",
            "Chile, you just poured out somethin' real. That weight you been carryin'? It's a little lighter now. Trust the process, hear?",
            "Now that's what healin' sound like. Ain't gotta be pretty. Ain't gotta be perfect. Just gotta be honest. And you was honest just now.",
            "Sugar, the ancestors said this: 'A burden shared is a burden halved.' You shared it with the wind, with God, with yourself. That's medicine.",
            "I feel that in my spirit. You spoke from your gut, from your soul. That's where the truth live. And truth? Truth sets you free.",
            "Mmm. The oak tree don't grow overnight. It takes storms and sunshine both. What you just did? That's sunshine for your roots.",
        ]

        let index = Int(duration) % feedbacks.count
        drHopeFeedback = feedbacks[index]

        // Animate feedback appearance
        withAnimation(.easeInOut(duration: 0.5)) {
            showFeedback = true
            drHopeTalking = true
        }

        withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
            mouthPulse = 1.04
        }

        // Stop talking after a few seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                drHopeTalking = false
                mouthPulse = 1.0
            }
            withAnimation(.easeIn(duration: 0.4)) {
                showMoodSelector = true
            }
        }
    }

    private func saveJournalEntry() {
        guard let mood = selectedMood else { return }

        let entry = JournalEntry(
            content: "Voice journal - \(recorder.formattedDuration)",
            mood: mood.rawValue,
            duration: recorder.recordingDuration,
            drHopeFeedback: drHopeFeedback,
            createdAt: Date()
        )
        modelContext.insert(entry)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            savedEntry = true
        }
    }
}
