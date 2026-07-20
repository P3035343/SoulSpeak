import Foundation
import AVFoundation

/// Text-to-speech service for Dr. Hope and Mr. Hope to "talk back" to the user.
/// Uses Apple's AVSpeechSynthesizer for natural voice output.
@MainActor
class TextToSpeechService: ObservableObject {
    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    /// Speak text aloud as the given character.
    func speak(_ text: String, as character: GeminiService.Character) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)

        // Configure voice based on character
        switch character {
        case .drHope:
            // Warm, slower female voice
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.42
            utterance.pitchMultiplier = 0.95
            utterance.volume = 0.9
            utterance.preUtteranceDelay = 0.3

        case .mrHope:
            // Energetic, slightly faster male voice
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.48
            utterance.pitchMultiplier = 0.85
            utterance.volume = 0.9
            utterance.preUtteranceDelay = 0.2
        }

        isSpeaking = true
        synthesizer.speak(utterance)

        // Monitor when speaking finishes
        Task {
            while synthesizer.isSpeaking {
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            }
            isSpeaking = false
        }
    }

    /// Stop speaking immediately.
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}
