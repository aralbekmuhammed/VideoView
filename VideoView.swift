//
//  VideoView.swift
//  Test
//
//  Created by Muhammed Aralbek on 14.06.2023.
//

import UIKit
import AVKit
import Combine

final class VideoView: UIView {
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.player = player
        return layer
    }()
    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    var gravity: AVLayerVideoGravity {
        get{
            playerLayer.videoGravity
        }set{
            playerLayer.videoGravity = newValue
        }
    }
    
    var isLoop = false
    
    var speed: Float = 1 {
        didSet{
            if player.rate != 0{
                player.rate = speed
            }
        }
    }
    
    @Published private(set) var isPlaying = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupObservers()
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = layer.bounds
    }
    
    func configure(with url: URL) {
        if let currentItem = player.currentItem{
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentItem)
        }
        
        stop()
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: item)
    }
    
    func play() {
        player.play()
        player.rate = speed
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.seek(to: .zero)
    }
    
    private func setupObservers(){
        player.publisher(for: \.rate).sink { [weak self] rate in
            self?.isPlaying = rate > 0
        }.store(in: &subscriptions)
    }
    
    @objc
    private func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            stop()
            play()
        }
    }
    
}
