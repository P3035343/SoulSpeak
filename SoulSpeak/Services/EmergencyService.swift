import Foundation
import AVFoundation
import UIKit

/// Emergency Crisis Service — activated by the emergency button.
///
/// When triggered:
/// 1. Starts recording a voice message automatically
/// 2. Plays Dr. Hope or Mr. Hope crisis talk-down audio
/// 3. After recording stops, sends the recording to emergency contact
/// 4. Auto-dials emergency contact phone number
///
/// This feature is designed for:
/// - Suicidal thoughts
/// - Substance relapse urges
/// - Severe anxiety/panic attacks
/// - Self-harm urges
@MainActor
class EmergencyService: ObservableObject {
    @Published var isInEmergencyMode = false
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var emergencyMessage: String = ""

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var recordingURL: URL?

    static let shared = EmergencyService()

    // MARK: - Activate Emergency

    /// Activate emergency mode — starts recording + plays talk-down.
    func activateEmergency() {
        isInEmergencyMode = true
        startRecording()
    }

    /// Deactivate emergency mode and contact emergency person.
    func deactivateAndContact(
        emergencyName: String,
        emergencyPhone: String,
        userName: String
    ) {
        stopRecording()
        isInEmergencyMode = false

        // Call emergency contact
        callEmergencyContact(phone: emergencyPhone)

        // Send SMS with context (opens Messages app)
        sendEmergencyText(
            phone: emergencyPhone,
            contactName: emergencyName,
            userName: userName
        )
    }

    // MARK: - Recording

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("[SoulSpeak Emergency] Audio session error: \(error)")
            return
        }

        let fileName = "emergency_\(Date().timeIntervalSince1970).m4a"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        recordingURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.recordingDuration += 1.0
                }
            }
        } catch {
            print("[SoulSpeak Emergency] Recording error: \(error)")
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
    }

    // MARK: - Contact Emergency Person

    private func callEmergencyContact(phone: String) {
        let cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        guard let url = URL(string: "tel://\(cleaned)") else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    private func sendEmergencyText(phone: String, contactName: String, userName: String) {
        let cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        let message = "URGENT: \(userName) activated their SoulSpeak emergency button. They need you right now. Please reach out to them immediately. This is an automated safety message."
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "sms:\(cleaned)&body=\(encodedMessage)") else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Crisis Talk-Down Messages

    /// Get a Dr. Hope crisis intervention message.
    static func drHopeCrisisMessage(userName: String, isSubstance: Bool) -> String {
        if isSubstance {
            return """
            Baby, I know that urge feels like it's bigger than you right now. But listen to me — \
            you have made it THIS far. \(userName), you are STRONGER than this craving. \
            It's lying to you. It's telling you one more time won't hurt. But we both know that's not true. \
            \
            Close your eyes. Breathe with me. In... hold... out. \
            \
            Think about why you started this journey. Think about who loves you. \
            Think about the person you're becoming. THAT person doesn't need this. \
            \
            You are not your addiction. You are a child of God fighting a war most people can't see. \
            And you are WINNING. Don't give that up for a moment of false relief. \
            \
            I'm right here. Your emergency contact is being notified. You are not alone.
            """
        } else {
            return """
            \(userName), baby, I need you to hear me right now. \
            Whatever darkness is telling you — it is LYING. \
            \
            You matter. Your life matters. The world needs you in it. \
            \
            I know it hurts. I know it feels like too much. But this feeling? It's temporary. \
            It will pass. It always does. And on the other side of this moment is another sunrise. \
            \
            Breathe with me. In through your nose... out through your mouth. Again. \
            \
            You don't have to fight this alone. Your emergency contact is being notified right now. \
            Help is coming. Just hold on, sugar. Just hold on. \
            \
            The ancestors didn't carry you this far to leave you. God didn't make you to end here. \
            You have purpose. You have people. You have ME. We're going to get through this together.
            """
        }
    }

    /// Get a Mr. Hope crisis intervention message.
    static func mrHopeCrisisMessage(userName: String, isSubstance: Bool) -> String {
        if isSubstance {
            return """
            Champ. Stop. Look at me. \
            \
            I know what you're thinking right now. And I need you to know — that voice in your head? \
            That's not YOU talking. That's the addiction talking. And we don't listen to it anymore. \
            \
            \(userName), you've come TOO FAR. Remember your streak. Remember your WHY. \
            Remember the last time you gave in — how did you feel after? \
            \
            This moment will pass. I PROMISE you it will pass. \
            \
            Call someone. Call your sponsor. Call ME. Don't pick that up. Don't go to that place. \
            \
            Your contact is being reached right now. You're not in this alone, Champ. \
            Champions don't quit — they call for backup. And backup is ON THE WAY.
            """
        } else {
            return """
            CHAMP. Listen to me. Right now. \
            \
            I don't care what happened today. I don't care how bad it feels. \
            You are NOT defined by this moment. You are NOT your worst thought. \
            \
            \(userName) — you are someone's reason to smile. You are someone's answered prayer. \
            And this world is BETTER with you in it. \
            \
            I need you to do ONE thing right now: take one breath. Just one. \
            \
            Good. Now another one. \
            \
            Your emergency contact is being notified. Someone who loves you is about to reach out. \
            Just hang on. Just keep breathing. \
            \
            I believe in you, Champ. I've ALWAYS believed in you. \
            This is just a bad moment — not a bad life. You hear me?
            """
        }
    }
}
