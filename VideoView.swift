import UIKit
import AVKit
import AVFoundation

class VideoView: UIView {
    var playerLayer: AVPlayerLayer? = AVPlayerLayer()
    var player: AVPlayer? = AVPlayer()
    var isLoop: Bool = false
    var rate: Float = 1
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
    func configureVideo(withURL url: URL?, rate: Float = 1, loops: Bool = true, contentMode: AVLayerVideoGravity = .resizeAspect) {
        if let url = url {
            self.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        }else{
            self.player?.replaceCurrentItem(with: nil)
        }
        self.rate = rate
        self.isLoop = loops
        playerLayer?.player = self.player
        playerLayer?.videoGravity = contentMode 
        if let playerLayer = self.playerLayer {
            layer.sublayers?.removeAll(where: {$0 is AVPlayerLayer})
            layer.addSublayer(playerLayer)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    func isPlaying()->Bool{
        player?.rate != 0 && player?.error == nil
    }
    func play() {
        player?.play()
        player?.rate = rate
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
            player?.rate = rate
        }
    }
}
