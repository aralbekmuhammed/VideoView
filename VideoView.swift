import UIKit
import AVKit
import AVFoundation

class VideoView: UIView {
    var playerLayer: AVPlayerLayer? = AVPlayerLayer()
    var player: AVPlayer? = AVPlayer()
    var isLoop: Bool = false
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    private func updateFrames(){
        playerLayer?.frame = layer.bounds
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    func configureVideo(withName name: String, loops: Bool = true, contentMode: AVLayerVideoGravity = .resizeAspect) {
        guard let path = Bundle.main.path(forResource: name, ofType:"mp4") else {
            debugPrint("video not found")
            return
        }
        self.player?.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: path)))
        self.isLoop = loops
        playerLayer?.player = self.player
        playerLayer?.videoGravity = contentMode 
        if let playerLayer = self.playerLayer {
            layer.sublayers?.removeAll(where: {$0 is AVPlayerLayer})
            layer.addSublayer(playerLayer)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    func play() {
        player?.play()
    }
    func pause() {
        player?.pause()
    }
    func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
    }
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            player?.pause()
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }
}
