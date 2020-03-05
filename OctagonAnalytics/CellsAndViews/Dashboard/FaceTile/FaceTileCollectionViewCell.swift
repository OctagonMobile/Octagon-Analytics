//
//  FaceTileCollectionViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 10/22/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class FaceTileCollectionViewCell: TileBaseCollectionViewCell {

    var faceTile: FaceTile? {
        didSet {
            setupCell()
        }
    }

    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        faceImageView?.contentMode = .scaleAspectFit
        faceImageView?.style(.roundCorner(5.0, 1.0, CurrentTheme.separatorColor))

    }
    
    override func setupCell() {
        super.setupCell()
        
        guard faceTile?.thumbnailImage == nil  else {
            faceImageView.image = faceTile?.thumbnailImage
            return
        }
        
        faceImageView.image = nil

        guard let urlString = faceTile?.faceUrl  else {
            return
        }
        
        imageLoadingIndicator.startAnimating()
        
        DataManager.shared.loadImage(imageUrl: urlString) { [weak self] (image, error) in
            
            self?.imageLoadingIndicator.stopAnimating()

            guard error == nil else {
                self?.faceImageView.image = nil
                self?.faceTile?.thumbnailImage = nil
                return
            }

            self?.faceImageView.image = image as? UIImage
            self?.faceTile?.thumbnailImage = image as? UIImage
            
            self?.faceImageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            UIView.animate(withDuration: 0.5, animations: {
                self?.faceImageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }

    }

}
