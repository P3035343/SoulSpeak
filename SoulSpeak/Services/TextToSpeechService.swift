import Foundation
import AVFoundation

/// Text-to-speech service for Dr. Hope and Mr. Hope to "talk back" to the user.
/// Uses Apple's AVSpeechSynthesizer with specific voice selections that
/// match each character's personality — warm female for Dr. Hope, deep male for Mr. Hope.
@MainActor
class TextToSpeechService: ObservableObject {
    @Published var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    /// Speak text aloud as the given character with their unique voice.
    func speak(_ text: String, as character: GeminiService.Character) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)

        // Select the best available voice for each character
        switch character {
        case .drHope:
            // Dr. Hope: Warm, soulful, slower female voice
            // Try premium voices first, then fall back
            if let voice = findBestVoice(for: .drHope) {
                utterance.voice = voice
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
            utterance.rate = 0.38          // Slow, deliberate — like she's thinking with you
            utterance.pitchMultiplier = 1.0 // Natural warm female pitch
            utterance.volume = 0.92
            utterance.preUtteranceDelay = 0.4  // Pause before speaking — feels reflective
            utterance.postUtteranceDelay = 0.2

        case .mrHope:
            // Mr. Hope: Energetic, confident, deeper male voice
            if let voice = findBestVoice(for: .mrHope) {
                utterance.voice = voice
            } else {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
            utterance.rate = 0.44          // Slightly faster — energetic but clear
            utterance.pitchMultiplier = 0.82 // Deeper, masculine tone
            utterance.volume = 0.95
            utterance.preUtteranceDelay = 0.2  // Quick to respond — he's engaged
            utterance.postUtteranceDelay = 0.1
        }

        isSpeaking = true
        synthesizer.speak(utterance)

        // Monitor when speaking finishes
        Task {
            while synthesizer.isSpeaking {
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
            isSpeaking = false
        }
    }

    /// Stop speaking immediately.
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: - Voice Selection

    /// Find the best available voice for each character.
    /// Prefers premium/enhanced voices that sound more natural.
    private func findBestVoice(for character: GeminiService.Character) -> AVSpeechSynthesisVoice? {
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        let englishVoices = allVoices.filter { $0.language.starts(with: "en") }

        switch character {
        case .drHope:
            // Prefer these voices for Dr. Hope (warm female):
            // "Samantha" (premium), "Allison", "Ava", "Zoe", "Susan"
            let preferredNames = ["Samantha", "Allison", "Ava", "Zoe", "Susan", "Karen"]
            for name in preferredNames {
                if let voice = englishVoices.first(where: {
                    $0.name.contains(name) && $0.quality == .enhanced
                }) {
                    return voice
                }
            }
            // Fall back to any enhanced female-typical English voice
            for name in preferredNames {
                if let voice = englishVoices.first(where: { $0.name.contains(name) }) {
                    return voice
                }
            }
            return nil

        case .mrHope:
            // Prefer these voices for Mr. Hope (confident male):
            // "Aaron" (premium), "Tom", "Daniel", "Fred", "Ralph"
            let preferredNames = ["Aaron", "Tom", "Daniel", "Fred", "Ralph", "Lee"]
            for name in preferredNames {
                if let voice = englishVoices.first(where: {
                    $0.name.contains(name) && $0.quality == .enhanced
                }) {
                    return voice
                }
            }
            // Fall back to any male-typical English voice
            for name in preferredNames {
                if let voice = englishVoices.first(where: { $0.name.contains(name) }) {
                    return voice
                }
            }
            return nil
        }
    }

    /// List available voices (useful for debugging which voices are on the device).
    func listAvailableVoices() -> [(name: String, language: String, quality: String)] {
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: "en") }
            .map { ($0.name, $0.language, $0.quality == .enhanced ? "Enhanced" : "Default") }
            .sorted { $0.name < $1.name }
    }
}
