import Foundation
import AVFoundation

/// Audio player service for character voices, background music, and ambient sounds.
@MainActor
class AudioPlayerService: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTrack: String = ""
    @Published var volume: Float = 0.7
    
    private var voicePlayer: AVAudioPlayer?
    private var musicPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    
    static let shared = AudioPlayerService()
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    // MARK: - Voice Playback (Mr. Hope / Dr. Hope)
    
    /// Play a character's voice file.
    /// File should be in the app bundle as "mr_hope_greeting.mp3" etc.
    func playVoice(fileName: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Voice file not found: \(fileName).\(fileExtension)")
            return
        }
        
        do {
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.volume = volume
            voicePlayer?.play()
            isPlaying = true
            currentTrack = fileName
        } catch {
            print("Voice playback failed: \(error)")
        }
    }
    
    func stopVoice() {
        voicePlayer?.stop()
        isPlaying = false
    }
    
    // MARK: - Background Music
    
    /// Play ambient/relaxing background music on loop.
    func playBackgroundMusic(fileName: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Music file not found: \(fileName).\(fileExtension)")
            return
        }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.volume = volume * 0.3 // Lower volume for background
            musicPlayer?.numberOfLoops = -1 // Loop forever
            musicPlayer?.play()
        } catch {
            print("Music playback failed: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        musicPlayer?.stop()
    }
    
    func setMusicVolume(_ volume: Float) {
        musicPlayer?.volume = volume * 0.3
    }
    
    // MARK: - Ambient Sounds
    
    /// Play ambient sounds (rain, ocean, birds, etc.)
    func playAmbient(fileName: String, fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Ambient file not found: \(fileName).\(fileExtension)")
            return
        }
        
        do {
            ambientPlayer = try AVAudioPlayer(contentsOf: url)
            ambientPlayer?.volume = volume * 0.2
            ambientPlayer?.numberOfLoops = -1
            ambientPlayer?.play()
        } catch {
            print("Ambient playback failed: \(error)")
        }
    }
    
    func stopAmbient() {
        ambientPlayer?.stop()
    }
    
    // MARK: - Master Controls
    
    func stopAll() {
        voicePlayer?.stop()
        musicPlayer?.stop()
        ambientPlayer?.stop()
        isPlaying = false
    }
    
    func setVolume(_ newVolume: Float) {
        volume = newVolume
        voicePlayer?.volume = newVolume
        musicPlayer?.volume = newVolume * 0.3
        ambientPlayer?.volume = newVolume * 0.2
    }
}
