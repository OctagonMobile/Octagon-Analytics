//
//  TileImageCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/26/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class TileImageCollectionViewCell: TileBaseCollectionViewCell {

    public typealias SaveImageBlock = (_ image: UIImage ,_ error: Error?) -> Void
    public typealias SearchImageBlock = (_ tile: Tile?) -> Void
    public typealias ImageTapActionBlock = (_ sender: TileImageCollectionViewCell,_ tile: Tile?) -> Void

    var saveImageBlock: SaveImageBlock?
    var searchImageBlock: SearchImageBlock?
    var imageTapBlock: ImageTapActionBlock?

    @IBOutlet weak var blurrView: UIVisualEffectView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var saveImageButton: UIButton!
    
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        addThumbnailView()

        blurrView.isHidden = true
        searchButton.style(.roundCorner(2.0, 1.0, .white))
        saveImageButton.style(.roundCorner(2.0, 1.0, .white))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TileImageCollectionViewCell.blurrViewTapGestureHandler(_:)))
        blurrView.addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        blurrView.isHidden = true
    }
    
    //MARK: Gesture Recognizer
    override func thumbnailViewTapGestureHandler(_ gesture: UITapGestureRecognizer) {

        imageTapBlock?(self, tile)

        // SHOW blurr view
//        self.blurrView.isHidden = false
//        self.blurrView.alpha = 0.0
//        UIView.animate(withDuration: 0.3, animations: {
//            self.blurrView.alpha = 1.0
//        })

    }
    
    @objc func blurrViewTapGestureHandler(_ gesture: UITapGestureRecognizer) {
        // Hide blurr view
        self.blurrView.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.blurrView.alpha = 0.0
            
        }) { (status) in
            self.blurrView.isHidden = true
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        saveImageBlock?(image,error)
    }

    //MARK: Button Action
    @IBAction func saveImageButtonAction(_ sender: UIButton) {
        guard let image = tile?.thumbnailImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        searchImageBlock?(tile)
    }
}
