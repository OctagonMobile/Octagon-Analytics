//
//  TileAudioCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 12/13/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import AVKit
import AlamofireImage

class TileAudioCollectionViewCell: TileBaseCollectionViewCell {
    
    private var mediaPlayer: VLCMediaPlayer?
    fileprivate var wasPlayingBeforeSliderMoved: Bool   =   false
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var audioTimeLabel: UILabel!
    @IBOutlet weak var audioSlider: UISlider!
    
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    override func setupCell() {
        super.setupCell()
        
        updateAudioThumbnailImage()
        updateUI()

    }
    
    //MARK: Private
    private func initialSetup() {
        playButton.setImage(UIImage(named: "TrackingPlayIcon"), for: .normal)

        audioSlider.setThumbImage(UIImage(named: "playerSliderHolder"), for: .normal)
        audioSlider.minimumTrackTintColor = CurrentTheme.standardColor
        audioSlider.maximumTrackTintColor = CurrentTheme.sliderTrackColor
        audioTimeLabel.textColor = CurrentTheme.titleColor
        
        audioImageView?.contentMode = .scaleAspectFit
        audioImageView?.backgroundColor = CurrentTheme.cellBackgroundColorSecondary
        containerView?.backgroundColor = CurrentTheme.cellBackgroundColor
        
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.delegate = self
    }


    fileprivate func updateUI() {
        guard let urlString = tile?.audioUrl, let url = URL(string: urlString) else { return }

        let media = VLCMedia(url: url)
        mediaPlayer?.media = media
        
        audioSlider.addTarget(self, action: #selector(TileAudioCollectionViewCell.playbackSliderValueChanged(_:)), for: .valueChanged)
        audioSlider.addTarget(self, action: #selector(TileAudioCollectionViewCell.playbackEditingDidEnd(_:)), for: .touchUpInside)
    }
    
    @objc func playbackEditingDidEnd(_ playbackSlider:UISlider)  {
        
        if wasPlayingBeforeSliderMoved {
            mediaPlayer?.play()
        }
        
        let imageName = mediaPlayer?.isPlaying == true ? "TrackingPauseIcon" : "TrackingPlayIcon"
        playButton.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)  {
        

        mediaPlayer?.pause()
        
        if let currentTime = mediaPlayer?.time.value, let remainingTime = mediaPlayer?.remainingTime.value {
            let totalTime = currentTime.floatValue + abs(remainingTime.floatValue)
            let updatedTime = playbackSlider.value * totalTime

            let time = VLCTime(number: NSNumber(value: updatedTime))
            perform(#selector(TileAudioCollectionViewCell.updateTime(_:)), with: time, afterDelay: 0.0)
        }
    }

    @objc func updateTime(_ time: VLCTime) {
        mediaPlayer?.time = time
        audioTimeLabel.text = time.stringValue
    }
    
    private func updateAudioThumbnailImage() {
        
        guard let thumbnailUrlString = tile?.thumbnailUrl, let thumbnailUrl = URL(string: thumbnailUrlString)  else { return }
        
        imageActivityIndicator.startAnimating()
        audioImageView.af.setImage(withURL: thumbnailUrl, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.flipFromTop(1.0), runImageTransitionIfCached: true) { [weak self] (response) in
            
            self?.imageActivityIndicator.stopAnimating()
            let image =  try? response.result.get()
            self?.tile?.thumbnailImage = image
        }
    }

    //Button Actions
    @IBAction func playButtonAction(_ sender: UIButton) {
        
        if mediaPlayer?.isPlaying == true {
            playButton.setImage(UIImage(named: "TrackingPlayIcon"), for: .normal)
            mediaPlayer?.pause()
        } else {
            playButton.setImage(UIImage(named: "TrackingPauseIcon"), for: .normal)
            mediaPlayer?.play()
        }
    }
}

extension TileAudioCollectionViewCell: VLCMediaPlayerDelegate {
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        
        let imageName = mediaPlayer?.isPlaying == true ? "TrackingPauseIcon" : "TrackingPlayIcon"
        playButton.setImage(UIImage(named: imageName), for: .normal)
        wasPlayingBeforeSliderMoved = (mediaPlayer?.isPlaying == true)

        if mediaPlayer?.state == .stopped || mediaPlayer?.state == .ended {
            mediaPlayer?.stop()
            mediaPlayer?.time = VLCTime(number: NSNumber(value: 0))
            audioTimeLabel.text = mediaPlayer?.time.stringValue
            audioSlider.value = 0.0
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        audioTimeLabel.text = mediaPlayer?.time.stringValue
        
        guard let currentTime = mediaPlayer?.time.value, let remainingTime = mediaPlayer?.remainingTime.value else { return }
        let totalTime = currentTime.floatValue + abs(remainingTime.floatValue)
        let sliderValue = mediaPlayer?.time.value.floatValue ?? 0 / totalTime
        audioSlider.value = sliderValue
    }
    
}
