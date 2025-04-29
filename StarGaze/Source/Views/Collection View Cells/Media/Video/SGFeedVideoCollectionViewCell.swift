//
//  SGFeedVideoCollectionViewCell.swift
//  StarGaze
//
//  Created by Suraj Shetty on 21/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import CoreMedia
import NVActivityIndicatorView

class SGFeedVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var playerView: VideoPlayerView!
    @IBOutlet weak var bufferOverlayView: UIView!
    
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    private var timeObserver:Any?
    
    unowned var viewModel:SGMediaViewModel! {
        didSet {
            setPlayer(with: viewModel)
        }
    }
    
    deinit {
        if let token = timeObserver {
            playerView.removeTimeObserver(token)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configurePlayer()
        hideBuffer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pause()
    }
    
    func load(with url:URL, autoPlay:Bool) {
        playerView.load(for: url, shouldPlay: autoPlay)
//        if autoPlay == false  {
//            playerView.pause(reason: .userInteraction) //Since playerview auto plays on url loading
//        }
    }
    
    func play() {
        playerView.resume()
    }
    
    func pause() {
        playerView.pause(reason: .userInteraction)
    }
    
    private func configurePlayer() {
        
        playerView.contentMode = .scaleAspectFill
        playerView.stateDidChanged = { [weak self] state in
            guard let ref = self else { return }
            
            switch state {
            case .none : debugPrint("Playeer none state for \(ref.playerView.playerURL?.absoluteString ?? "")")
                self?.playerView.pause(reason: .hidden)
            case .loading: ref.showBuffer()
            case .paused(_, _):
                ref.playButton.setImage(UIImage(named: "play_video"), for: .normal)
            case .playing:
                ref.hideBuffer()
                ref.playButton.setImage(UIImage(named: "pause_video"), for: .normal)                
            case .error(let error): debugPrint("Player error \(error) \n for \(ref.playerView.playerURL?.absoluteString ?? "")")
            }
        }
    }
    
    private func showBuffer() {
        bufferOverlayView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideBuffer() {
        activityIndicator.stopAnimating()
        bufferOverlayView.isHidden = true
    }
    
    private func setPlayer(with model:SGMediaViewModel) {
        if let token = timeObserver {
            playerView.removeTimeObserver(token)
        }
        
        
        if let url = model.url {
            load(with: url, autoPlay: false)
            
            let interval = CMTimeMake(value: 1, timescale: 1) // 0.25 (1/4) seconds
            timeObserver = playerView.addPeriodicTimeObserver(forInterval: interval,
                                                              queue: .main) {[weak self] _ in
                guard let ref = self else { return }
                let current = ref.playerView.currentDuration
                let total = ref.playerView.totalDuration
                let left = Int(total - current)
                let minutes = left/60
                let seconds  = left%60
                
                ref.counterLabel.text = String(format: "%02d:%02d", minutes, seconds)//  "\(minutes):\(seconds)"
            }
        }
    }
}
