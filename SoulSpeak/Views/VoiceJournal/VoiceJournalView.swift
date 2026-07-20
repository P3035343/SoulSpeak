import SwiftUI
import SwiftData

/// Voice Journal Screen — immersive recording experience.
///
/// Before recording: Office background with record button prompt.
/// During recording: Full-screen Dr. Hope "listening" — animated image of her
/// writing notes and looking up at the user. Feels like a real therapy session.
/// After recording: Dr. Hope's intelligent feedback + mood selector.
struct VoiceJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var recorder = VoiceRecorderService()
    @StateObject private var speechService = SpeechRecognitionService()
    @StateObject private var audioPlayer = AudioPlayerService.shared

    @State private var selectedMood: Mood?
    @State private var drHopeFeedback: String = ""
    @State private var drHopeFollowUp: String = ""
    @State private var showFeedback = false
    @State private var showMoodSelector = false
    @State private var showTranscription = false
    @State private var drHopeTalking = false
    @State private var mouthPulse: CGFloat = 1.0
    @State private var savedEntry = false
    @State private var showPermissionAlert = false
    @State private var showResponseVideo = false

    var body: some View {
        ZStack {
            if recorder.isRecording {
                // RECORDING STATE: Full-screen Dr. Hope listening
                recordingSessionView
                    .transition(.opacity)
            } else {
                // IDLE / POST-RECORDING STATE
                idleAndResultsView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: recorder.isRecording)
        .navigationTitle(recorder.isRecording ? "" : "Voice Journal")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            speechService.requestAuthorization()
        }
        .alert("Microphone & Speech Access", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("SoulSpeak needs microphone and speech recognition access to transcribe your journal entries. Please enable them in Settings.")
        }
    }

    // MARK: - Recording Session View (Full Screen Dr. Hope Listening)
    private var recordingSessionView: some View {
        ZStack {
            // Full-screen Dr. Hope image — she's writing and listening
            DrHopeListeningView()
                .ignoresSafeArea()

            // Overlay gradient at bottom for controls
            VStack {
                Spacer()
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
            }
            .ignoresSafeArea()

            // Recording controls floating at bottom
            VStack {
                // Top: subtle recording indicator
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .opacity(mouthPulse > 1.0 ? 1.0 : 0.5)
                        Text("Recording")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text(recorder.formattedDuration)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.5))
                    )
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Bottom: Stop button + waveform
                VStack(spacing: 16) {
                    // Mini waveform
                    WaveformView(levels: recorder.audioLevels, isActive: true, barColor: .white)
                        .frame(height: 30)
                        .padding(.horizontal, 40)

                    // Stop button
                    Button(action: stopRecording) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 72, height: 72)

                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                .frame(width: 72, height: 72)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.red)
                                .frame(width: 26, height: 26)
                        }
                    }

                    Text("Tap to stop")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Animate the recording pulse
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                mouthPulse = 1.05
            }
        }
    }

    // MARK: - Idle / Results View
    private var idleAndResultsView: some View {
        ZStack {
            // Office background
            Image("dr_hope_office_render")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 100)

                    // Pre-recording prompt
                    if !showFeedback && !savedEntry {
                        preRecordSection
                    }

                    // Dr. Hope response video (plays after recording stops)
                    if showResponseVideo {
                        responseVideoSection
                            .transition(.opacity)
                    }

                    // Dr. Hope feedback (appears after video)
                    if showFeedback {
                        feedbackCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Live transcription (shown after recording)
                    if showTranscription && !speechService.transcribedText.isEmpty && !recorder.isRecording {
                        transcriptionCard
                            .transition(.opacity)
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
    }

    // MARK: - Pre-Record Section
    private var preRecordSection: some View {
        VStack(spacing: 24) {
            // Small Dr. Hope avatar
            Image("dr_hope")
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.7, green: 0.4, blue: 0.8), lineWidth: 2)
                )
                .shadow(color: Color(red: 0.7, green: 0.4, blue: 0.8).opacity(0.4), radius: 6)

            Text("\"Go on, baby. Speak your truth.\nI'm right here listenin'.\"")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .italic()

            // Record button
            Button(action: startRecording) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 80, height: 80)

                    Circle()
                        .fill(Color.red)
                        .frame(width: 56, height: 56)
                }
            }

            Text("Tap to Record")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - Live Transcription Card
    private var transcriptionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                Text("What you shared")
                    .font(SSTypography.caption)
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
            }

            Text(speechService.transcribedText)
                .font(.system(size: 14, weight: .regular, design: .serif))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
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

            if !drHopeFollowUp.isEmpty {
                Divider()
                    .padding(.vertical, 4)

                HStack(spacing: 6) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 10))
                        .foregroundColor(SSColors.secondary.opacity(0.7))
                    Text(drHopeFollowUp)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundColor(SSColors.secondary)
                }
            }
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
    private func startRecording() {
        // Reset state
        savedEntry = false
        showFeedback = false
        showMoodSelector = false
        selectedMood = nil
        drHopeFeedback = ""
        drHopeFollowUp = ""

        // Check speech permission
        if speechService.authorizationStatus == .denied || speechService.authorizationStatus == .restricted {
            showPermissionAlert = true
            return
        }

        // Start recording + live transcription
        recorder.startRecording()
        speechService.startTranscribing()
        showTranscription = true

        // Play Dr. Hope intro when starting
        audioPlayer.playVoice(fileName: "dr_hope_intro")
    }

    private func stopRecording() {
        recorder.stopRecording()
        speechService.stopTranscribing()

        // Show Dr. Hope response video first
        withAnimation(.easeInOut(duration: 0.4)) {
            showResponseVideo = true
        }
    }

    // MARK: - Response Video Section
    private var responseVideoSection: some View {
        VStack(spacing: 12) {
            // Play dr_hope_response.mp4 in a rounded frame
            VideoPlayerView(
                videoName: "dr_hope_response",
                fileExtension: "mp4",
                looping: false,
                onVideoFinished: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showResponseVideo = false
                    }
                    generateIntelligentFeedback()
                }
            )
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.7, green: 0.4, blue: 0.8).opacity(0.4), lineWidth: 2)
            )
            .shadow(color: Color(red: 0.7, green: 0.4, blue: 0.8).opacity(0.3), radius: 10, y: 4)

            Text("Dr. Hope is reflecting...")
                .font(.system(size: 12, weight: .medium, design: .serif))
                .foregroundColor(.white.opacity(0.6))
                .italic()
        }
    }

    private func generateIntelligentFeedback() {
        let transcribedText = speechService.transcribedText

        if transcribedText.isEmpty {
            let fallbacks = [
                "Mmhmm, I hear you, baby. That took courage to let out. The swamp don't clear itself — you gotta wade through. And you wadin'. I'm proud of you.",
                "Chile, you just poured out somethin' real. That weight you been carryin'? It's a little lighter now. Trust the process, hear?",
                "Now that's what healin' sound like. Ain't gotta be pretty. Ain't gotta be perfect. Just gotta be honest. And you was honest just now.",
            ]
            drHopeFeedback = fallbacks[Int(recorder.recordingDuration) % fallbacks.count]
            drHopeFollowUp = "What's one thing you need to hear right now?"
        } else {
            drHopeFeedback = DrHopeResponseEngine.generateResponse(for: transcribedText)
            drHopeFollowUp = DrHopeResponseEngine.generateFollowUp(for: transcribedText)
        }

        withAnimation(.easeInOut(duration: 0.5)) {
            showFeedback = true
            drHopeTalking = true
        }

        withAnimation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true)) {
            mouthPulse = 1.04
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
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

        let transcription = speechService.transcribedText.isEmpty
            ? "Voice journal - \(recorder.formattedDuration)"
            : speechService.transcribedText

        let entry = JournalEntry(
            content: transcription,
            mood: mood.rawValue,
            duration: recorder.recordingDuration,
            drHopeFeedback: drHopeFeedback,
            createdAt: Date()
        )
        modelContext.insert(entry)

        NotificationService.shared.cancelStreakReminder()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            savedEntry = true
        }
    }
}
