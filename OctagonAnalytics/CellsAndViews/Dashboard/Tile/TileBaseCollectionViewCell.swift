//
//  TileBaseCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class TileBaseCollectionViewCell: UICollectionViewCell {

    var tile: Tile? {
        didSet {
            setupCell()
        }
    }
    
    fileprivate var thumbnailView: ThumbnailView?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var titleView: UIView!
    
    
    //MARK
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        infoButton?.style(.roundCorner((infoButton.frame.size.width / 2), 1.0))
        
        titleView?.backgroundColor = CurrentTheme.headerViewBackgroundColorSecondary
        containerView?.backgroundColor = CurrentTheme.cellBackgroundColorSecondary
        timestampLabel?.style(CurrentTheme.caption1TextStyle())
        containerView?.style(.roundCorner(5.0, 1.0, CurrentTheme.borderColor))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailView?.cancelImageDownloading()
    }
    
    func setupCell() {
        
        layoutIfNeeded()
        containerView.style(.shadow())
        
        timestampLabel?.text = tile?.timestampString
        thumbnailView?.enableErrorLabel = tile?.type == TileType.photo
        thumbnailView?.tile = tile
    }

    @discardableResult
    func addThumbnailView() -> ThumbnailView? {
        
        guard (holderView.viewWithTag(100) as? ThumbnailView) == nil else { return nil}
        
        thumbnailView = ThumbnailView(frame: holderView.frame)
        thumbnailView?.tag = 100
        thumbnailView?.clipsToBounds = true
        thumbnailView?.isUserInteractionEnabled = true
        thumbnailView?.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TileBaseCollectionViewCell.thumbnailViewTapGestureHandler(_:)))
        thumbnailView?.addGestureRecognizer(tapGesture)
        thumbnailView?.contentMode = .scaleAspectFit
        holderView.addSubview(thumbnailView!)
        
        var constraints = [NSLayoutConstraint]()
        let views: [String: UIView] = ["thumbnailView": thumbnailView!, "holderView": holderView]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[thumbnailView]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[thumbnailView]-0-|", options: [], metrics: nil, views: views)
        holderView?.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
        
        return thumbnailView
    }
    
    //MARK: Public Functions
    @objc func thumbnailViewTapGestureHandler(_ gesture: UITapGestureRecognizer)  {
        // handle thumbnail tap gesture
    }
    
    
    //MARK: Button Actions
    @IBAction func infoButtonAction(_ sender: UIButton) {
    }
}

