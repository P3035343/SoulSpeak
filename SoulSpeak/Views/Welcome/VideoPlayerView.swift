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

        // Ensure audio session allows video playback sound
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[SoulSpeak] Video audio session error: \(error)")
        }

        guard let url = Bundle.main.url(forResource: videoName, withExtension: fileExtension) else {
            print("[SoulSpeak] Video not found: \(videoName).\(fileExtension)")
            // If video not found, skip immediately
            DispatchQueue.main.async { [weak self] in
                self?.onVideoFinished?()
            }
            return
        }

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        // Buffer immediately for instant playback
        playerItem.preferredForwardBufferDuration = 5.0

        player = AVPlayer(playerItem: playerItem)
        player?.automaticallyWaitsToMinimizeStalling = false

        let avPlayerLayer = layer as! AVPlayerLayer
        avPlayerLayer.player = player
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayerLayer.backgroundColor = UIColor.black.cgColor

        // Observe when video ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        // Preroll then play for faster start
        player?.preroll(atRate: 1.0) { [weak self] finished in
            DispatchQueue.main.async {
                self?.player?.play()
            }
        }
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

    @State private var showSkip = false

    var body: some View {
        ZStack {
            VideoPlayerView(
                videoName: videoName,
                fileExtension: fileExtension,
                looping: looping,
                onVideoFinished: onFinished
            )
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .ignoresSafeArea()

            // Skip button (appears after 2 seconds for non-looping videos)
            if showSkip && !looping {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { onFinished?() }) {
                            Text("Skip")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.black.opacity(0.5)))
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            if !looping {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showSkip = true
                }
            }
        }
    }
}
