import SwiftUI

/// Vent Room recording phase — user records whatever they want to get off their chest.
/// Dark, moody room atmosphere. Red recording indicator.
struct VentRecordingView: View {
    @ObservedObject var recorder: VoiceRecorderService
    let onFinished: () -> Void

    @State private var pulseRed = false
    @State private var roomFlicker = false

    var body: some View {
        ZStack {
            // Dark moody room background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.05, blue: 0.05),
                    Color(red: 0.12, green: 0.06, blue: 0.06),
                    Color(red: 0.06, green: 0.04, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Fireplace glow in background
            VStack {
                Spacer()
                RadialGradient(
                    colors: [
                        Color(red: 0.9, green: 0.4, blue: 0.1).opacity(roomFlicker ? 0.15 : 0.08),
                        Color.clear
                    ],
                    center: .bottom,
                    startRadius: 20,
                    endRadius: 250
                )
                .frame(height: 200)
            }
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Vent room icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.1).opacity(0.8))

                Text(recorder.isRecording ? "Let it out..." : "Ready to vent?")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text(recorder.isRecording
                     ? "Say whatever you need to say.\nNo one will hear this but you."
                     : "Tap the button to start recording.\nThis is YOUR space.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                // Waveform when recording
                if recorder.isRecording {
                    WaveformView(levels: recorder.audioLevels, isActive: true, barColor: Color(red: 0.9, green: 0.3, blue: 0.2))
                        .frame(height: 40)
                        .padding(.horizontal, 40)

                    Text(recorder.formattedDuration)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.red.opacity(0.8))
                }

                Spacer()

                // Record / Stop button
                Button(action: toggleRecording) {
                    ZStack {
                        // Pulse ring when recording
                        if recorder.isRecording {
                            Circle()
                                .stroke(Color.red.opacity(0.4), lineWidth: 3)
                                .frame(width: 90, height: 90)
                                .scaleEffect(pulseRed ? 1.2 : 1.0)
                        }

                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 3)
                            .frame(width: 80, height: 80)

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

                Text(recorder.isRecording ? "Tap to finish" : "Tap to vent")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))

                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseRed = true
                roomFlicker = true
            }
        }
    }

    private func toggleRecording() {
        if recorder.isRecording {
            recorder.stopRecording()
            onFinished()
        } else {
            recorder.startRecording()
        }
    }
}
