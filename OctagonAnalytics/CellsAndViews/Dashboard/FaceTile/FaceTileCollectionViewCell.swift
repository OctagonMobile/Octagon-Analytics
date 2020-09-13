//
//  FaceTileCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/22/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import AlamofireImage

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

        guard let urlString = faceTile?.faceUrl, let url = URL(string: urlString) else {
            return
        }
        
        imageLoadingIndicator.startAnimating()
        faceImageView?.af.setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.curlDown(0.2), runImageTransitionIfCached: true) { [weak self] (response) in
            
            self?.imageLoadingIndicator.stopAnimating()
            guard let image =  try? response.result.get() else {
                self?.faceImageView.image = nil
                self?.faceTile?.thumbnailImage = nil
                return
            }
            
            self?.faceTile?.thumbnailImage = image
        }
    }

}
