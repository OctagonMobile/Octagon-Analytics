//
//  TileCarouselView.swift
//  KibanaGo
//
//  Created by Rameez on 1/17/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit
import AlamofireImage

class TileCarouselView: UIView {

    var tile: Tile? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet var imageView: UIImageView!

    @IBOutlet var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        errorLabel.text = "Unable to load image"
    }
    private func updateUI() {
        errorLabel.isHidden = true
        loadImage()
    }
    
    private func loadImage() {
        
        imageView.image = nil
        guard let urlString = tile?.imageUrl, let url = URL(string: urlString) else { return }
        imageActivityIndicator.startAnimating()
        imageView?.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: true) { [weak self] (response) in
            
            self?.imageActivityIndicator.stopAnimating()
            guard let _ = response.result.value else {
                self?.errorLabel.text = response.error?.localizedDescription
                self?.errorLabel.isHidden = false
                return
            }
            
            self?.errorLabel.isHidden = true
        }
        
    }

}
