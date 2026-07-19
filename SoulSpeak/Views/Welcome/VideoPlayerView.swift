import SwiftUI
import AVKit

/// Full-screen looping video player that plays bundled MP4 files.
/// Used for character intro videos (Dr. Hope, Mr. Hope).
struct VideoPlayerView: UIViewRepresentable {
    let videoName: String
    let fileExtension: String
    var looping: Bool = false
    var onVideoFinished: (() -> Void)? = nil

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.configure(videoName: videoName, fileExtension: fileExtension, looping: looping)
        view.onVideoFinished = onVideoFinished
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

/// UIView subclass that hosts an AVPlayerLayer for smooth video playback.
class PlayerUIView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var looping = false
    var onVideoFinished: (() -> Void)?

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    func configure(videoName: String, fileExtension: String, looping: Bool) {
        self.looping = looping

        guard let url = Bundle.main.url(forResource: videoName, withExtension: fileExtension) else {
            print("[SoulSpeak] Video not found: \(videoName).\(fileExtension)")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        let avPlayerLayer = layer as! AVPlayerLayer
        avPlayerLayer.player = player
        avPlayerLayer.videoGravity = .resizeAspect
        avPlayerLayer.backgroundColor = UIColor.black.cgColor

        // Observe when video ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        player?.play()
    }

    @objc private func videoDidEnd() {
        if looping {
            player?.seek(to: .zero)
            player?.play()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onVideoFinished?()
            }
        }
    }

    func stopPlayback() {
        player?.pause()
        player = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        (layer as? AVPlayerLayer)?.frame = bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.pause()
    }
}

/// SwiftUI wrapper for a looping background video with overlay content.
struct FullScreenVideoBackground: View {
    let videoName: String
    let fileExtension: String
    var looping: Bool = true
    var onFinished: (() -> Void)? = nil

    var body: some View {
        VideoPlayerView(
            videoName: videoName,
            fileExtension: fileExtension,
            looping: looping,
            onVideoFinished: onFinished
        )
        .ignoresSafeArea()
    }
}
