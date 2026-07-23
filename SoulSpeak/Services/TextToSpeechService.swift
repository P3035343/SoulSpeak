import Foundation
import AVFoundation

/// Text-to-speech using ElevenLabs API for Dr. Hope and Mr. Hope's
/// actual cloned voices. Falls back to Apple TTS if unavailable.
@MainActor
class TextToSpeechService: ObservableObject {
    @Published var isSpeaking = false

    private var audioPlayer: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()

    // ElevenLabs Voice IDs
    private let mrHopeVoiceID = "4OyvWLbRHLsY3GBjrXWX"
    private let drHopeVoiceID = "O8oEKeaG9DHHSKVcRQuq"

    private let elevenLabsAPIKey: String = {
        if let path = Bundle.main.path(forResource: "GeminiConfig", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["ELEVENLABS_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        return ""
    }()

    private let baseURL = "https://api.elevenlabs.io/v1/text-to-speech"

    func speak(_ text: String, as character: GeminiService.Character) {
        stop()
        if !elevenLabsAPIKey.isEmpty {
            Task { await speakWithElevenLabs(text, character: character) }
        } else {
            speakWithApple(text, character: character)
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    private func speakWithElevenLabs(_ text: String, character: GeminiService.Character) async {
        let voiceID = character == .drHope ? drHopeVoiceID : mrHopeVoiceID
        guard let url = URL(string: "\(baseURL)/\(voiceID)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        request.setValue(elevenLabsAPIKey, forHTTPHeaderField: "xi-api-key")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": [
                "stability": character == .drHope ? 0.6 : 0.5,
                "similarity_boost": 0.85,
                "style": character == .drHope ? 0.4 : 0.5,
                "use_speaker_boost": true
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                speakWithApple(text, character: character)
                return
            }

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("el_\(UUID().uuidString).mp3")
            try data.write(to: tempURL)

            audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
            audioPlayer?.volume = 0.95
            audioPlayer?.play()
            isSpeaking = true

            Task {
                while audioPlayer?.isPlaying == true {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
                isSpeaking = false
                try? FileManager.default.removeItem(at: tempURL)
            }
        } catch {
            speakWithApple(text, character: character)
        }
    }

    private func speakWithApple(_ text: String, character: GeminiService.Character) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = character == .drHope ? 0.38 : 0.44
        utterance.pitchMultiplier = character == .drHope ? 1.0 : 0.82
        utterance.volume = 0.9
        isSpeaking = true
        synthesizer.speak(utterance)
        Task {
            while synthesizer.isSpeaking {
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
            isSpeaking = false
        }
    }
}
