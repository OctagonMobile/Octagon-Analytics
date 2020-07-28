//
//  ThumbnailView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/27/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import OctagonAnalyticsService

class ThumbnailView: UIView {

    /// Play icon image view
    private var playImageView: UIImageView          = UIImageView()
    
    /// Thumbnail imageview to be display the thumbnail image
    private var thumbnailImageView: UIImageView     = UIImageView()
    
    /// Error Label
    private var errorLabel: UILabel                 = UILabel()

    /// Show play icon or not. (Default value = false)
    var showPlayIcon: Bool                          = false {
        didSet {
            if showPlayIcon { addPlayIconImageView() }
        }
    }
    
    var enableErrorLabel: Bool                  = false

    var imageActivityIndicator: UIActivityIndicatorView =   UIActivityIndicatorView()
    
    var tile: Tile? {
        didSet {
            updateThumbnailImage(nil)
        }
    }
    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addThumbnailImageView()
    }
    
    convenience init(frame: CGRect, thumbnailImage: UIImage? = nil) {
        self.init(frame: frame)
        
        tile?.thumbnailImage = thumbnailImage
        addThumbnailImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Play Image
    /**
     Adds Play icon image view.
     */
    private func addPlayIconImageView() {
        
        playImageView.image = UIImage(named: "play")
        playImageView.contentMode = .scaleAspectFit
        playImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playImageView)
        let centerX = NSLayoutConstraint(item: playImageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: playImageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        
        if isIPhone {
            // Add height n width
            let height = NSLayoutConstraint(item: playImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 50)
            let width = NSLayoutConstraint(item: playImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 50)
            self.addConstraints([height, width])
        }
        self.addConstraints([centerX, centerY])
    }
    
    /**
     Adds Thumbnail image view.
     */
    private func addThumbnailImageView() {
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.contentMode = .scaleAspectFit
        self.addSubview(thumbnailImageView)
        
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center
        errorLabel.style(CurrentTheme.caption1TextStyle())
        errorLabel.text = "Not found"
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(errorLabel)

        var constraints = [NSLayoutConstraint]()
        let view = self
        let views: [String: UIView] = ["thumbnailImageView": thumbnailImageView, "errorLabel": errorLabel, "view": view]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[thumbnailImageView]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[thumbnailImageView]-0-|", options: [], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[errorLabel]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[errorLabel]-0-|", options: [], metrics: nil, views: views)

        self.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
        
        imageActivityIndicator.color = CurrentTheme.titleColor
        imageActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageActivityIndicator)
        bringSubviewToFront(imageActivityIndicator)
        
        let xConstraint = NSLayoutConstraint(item: imageActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: imageActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        addConstraints([xConstraint, yConstraint])
        NSLayoutConstraint.activate([xConstraint, yConstraint])
    }
    
    /**
     Updates the thumbnail image.
     
     - parameter image: thumbnail image.
     */
    
    func updateThumbnailImage(_ completion: ((UIImage?) -> Void)?) {
        
        guard let thumbnailUrlString = tile?.thumbnailUrl, let thumbnailUrl = URL(string: thumbnailUrlString)  else { return }
        
        thumbnailImageView.image = nil
        imageActivityIndicator.startAnimating()
        ImageResponseSerializer.addAcceptableImageContentTypes(["image/svg+xml"])
        thumbnailImageView.af.setImage(withURL: thumbnailUrl, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.flipFromTop(1.0), runImageTransitionIfCached: true) { [weak self] (response) in
            
            self?.imageActivityIndicator.stopAnimating()
            guard let image = try? response.result.get() else {
                if self?.enableErrorLabel == true {
                    self?.errorLabel.isHidden = false
                }
                completion?(nil)
                return
            }

            self?.errorLabel.isHidden = true
            self?.tile?.thumbnailImage = image
            self?.thumbnailImageView.image = image
            completion?(image)
        }
    }

    /**
     Cancel's image downloading if any active downloading.

     */
    func cancelImageDownloading() {
        thumbnailImageView.image = nil
        thumbnailImageView.af.cancelImageRequest()
    }
}
