//
//  TileVideoCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 12/10/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TileVideoCollectionViewCell: TileBaseCollectionViewCell {
    
    var playerController: AVPlayerViewController?
    var player: AVPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setupCell() {
        super.setupCell()
        updateUI(shouldPlayVideo: false)
    }
    
    func updateUI(shouldPlayVideo: Bool) {
        
        if shouldPlayVideo {
            guard let urlString = tile?.videoUrl, let url = URL(string: urlString) else { return }
            
            let avAsset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: avAsset)
            player = AVPlayer(playerItem: playerItem)
            playerController = AVPlayerViewController()
            playerController?.player = player
            playerController?.view.frame = holderView?.bounds ?? CGRect.zero
            guard let videoView = playerController?.view else { return }
            videoView.tag = 101
            holderView.addSubview(videoView)
            player?.play()
            holderView.viewWithTag(100)?.removeFromSuperview()
        } else {

            createThumbnailView()
            playerController = nil
            player = nil
            holderView.viewWithTag(101)?.removeFromSuperview()
        }
    }
    
    private func createThumbnailView() {
        let thumbnail = addThumbnailView()
        thumbnail?.tile = tile
        thumbnail?.showPlayIcon = true
    }
        
    @objc override func thumbnailViewTapGestureHandler(_ gesture: UITapGestureRecognizer)  {
        // Remove Thumbnail & Add Video Player
        updateUI(shouldPlayVideo: true)
    }
}
