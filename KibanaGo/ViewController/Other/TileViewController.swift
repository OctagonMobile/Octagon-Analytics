//
//  TileViewController.swift
//  KibanaGo
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD
import TGPControls

class TileViewController: PanelBaseViewController {

    @IBOutlet var tileSlider: TGPDiscreteSlider!
    @IBOutlet weak var tilesCollectionView: UICollectionView!
    
    let minCellSize: CGFloat = 180.0

    var dataSource: [Tile] {
        return (panel as? TilePanel)?.tileList ?? []
    }
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tilesCollectionView.register(UINib(nibName: NibName.tileImageCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.tileCellId)
        tilesCollectionView.register(UINib(nibName: NibName.tileVideoCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.tileVideoCellId)
        tilesCollectionView.register(UINib(nibName: NibName.tileAudioCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.tileAudioCellId)

        (tilesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 0.0
        (tilesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 0.0
        
        let iconName = CurrentTheme.isDarkTheme ? "sliderHolder-Dark" : "sliderHolder"
        let image = UIImage(named: iconName)
        tileSlider.thumbImage = image
        tileSlider.thumbStyle = ComponentStyle.image.rawValue
        tileSlider.minimumTrackTintColor = CurrentTheme.sliderTrackColor
        tileSlider.maximumTrackTintColor = CurrentTheme.sliderTrackColor
        tileSlider.addTarget(self, action: #selector(sliderAction(_:)), for: .touchUpInside)
        tileSlider.addTarget(self, action: #selector(sliderAction(_:)), for: .touchUpOutside)

        tilesCollectionView.backgroundColor = CurrentTheme.cellBackgroundColor
    }
    
    override func didDeviceRotationCompleted() {
        super.didDeviceRotationCompleted()
        setupLayout()
    }

    func setupLayout() {
        
        tileSlider.minimumValue = isLandscapeMode ? 2 : 1
        let val = Double(tilesCollectionView.frame.width / minCellSize)
        tileSlider.tickCount        = Int(val)
        tileSlider.incrementValue   = 1
        tileSlider.value = isLandscapeMode ? CGFloat(val) + 1 : CGFloat(val)
        sliderAction(tileSlider)
    }
    
    private func isAudioType() -> Bool {
        return dataSource.first?.type == TileType.audio
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        setupLayout()
    }
    
    @objc func sliderAction(_ sender: TGPDiscreteSlider) {
        tilesCollectionView.reloadData()
    }

    fileprivate func didSaveImage(image: UIImage, error: Error?) {
        
        var title   = ""
        var message = ""
        if let error = error {
            
            title = "Error"
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .authorized {
                message = error.localizedDescription
            } else {
                message = "Please go to settings and allow permission to access the photos"
            }
        } else {
            title = "Saved!"
            message = "Image saved successfully"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = CurrentTheme.titleColor
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)


    }
}

extension TileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tile = dataSource[indexPath.row]
        
        var cellId = ""
        if tile.type == .photo {
            cellId = CellIdentifiers.tileCellId
        } else if tile.type == .video {
            cellId = CellIdentifiers.tileVideoCellId
        } else if tile.type == .audio {
            cellId = CellIdentifiers.tileAudioCellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? TileBaseCollectionViewCell
        cell?.tile = tile
        
        if tile.type == .photo {
            let imageCell = cell as? TileImageCollectionViewCell
            
            imageCell?.imageTapBlock = { [weak self] (sender, tile) in
                self?.showInfoScreen(tile)
            }
            
/* // Disable save photo & search photo feature
            imageCell?.saveImageBlock = { [weak self] (image, error) in
                self?.didSaveImage(image: image, error: error)
            }


            imageCell?.searchImageBlock = { [weak self] (tile) in

                guard let tilePanel = (self?.panel as? TilePanel) else { return }

                let hud = MBProgressHUD.showAdded(to: self?.view ?? UIView(), animated: true)
                hud.animationType = .zoomIn
                hud.contentColor = CurrentTheme.darkBackgroundColor

                tile?.loadImageHashesFor(tilePanel, { [weak self] (result, error) in

                    hud.hide(animated: true)

                    guard error == nil else {
                        // Show Alert
                        self?.showAlert(error?.localizedDescription)
                        return
                    }

                    guard let imageHashArray = result as? [String], let strongSelf = self else {
                        return
                    }

                    let fieldName = (self?.panel?.visState as? TileVisState)?.imageHashField ?? ""
                    let imageFilter = ImageFilter(fieldName: fieldName, fieldValue: imageHashArray)
                    self?.selectFieldAction?(strongSelf, imageFilter, nil)
                })
            }
 */
        }
        return cell ?? TileBaseCollectionViewCell()
    }
    
    private func showInfoScreen(_ tile: Tile?) {
        let storyboard = StoryboardManager.shared.storyBoard(.charts)
        guard let infoViewCtr = storyboard.instantiateViewController(withIdentifier: StoryboardId.tileInfoViewController) as? TileInfoViewController else {
            return
        }
        
        infoViewCtr.tileList = dataSource
        infoViewCtr.selectedTile = tile
        
        let nav = UINavigationController(rootViewController: infoViewCtr)
        present(nav, animated: true, completion: nil)
    }
}

extension TileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard dataSource.count > 0, tileSlider.value > 0 else { return CGSize.zero }
        
        let max = CGFloat(tileSlider.tickCount) + tileSlider.minimumValue - 1
        let val = tileSlider.minimumValue + max - tileSlider.value
        let width = collectionView.frame.width / val
        let height = isAudioType() ? width / 1.4 : width * 1.1
        return CGSize(width: width, height: height)
    }

}

extension TileViewController {
    
    struct StoryboardId {
        static let tileInfoViewController = "TileInfoViewController"
    }
    
    struct NibName {
        static let tileImageCollectionViewCell = "TileImageCollectionViewCell"
        static let tileVideoCollectionViewCell = "TileVideoCollectionViewCell"
        static let tileAudioCollectionViewCell = "TileAudioCollectionViewCell"
    }

    struct CellIdentifiers {
        static let tileCellId = "tileCellId"
        static let tileVideoCellId = "tileVideoCellId"
        static let tileAudioCellId = "tileAudioCellId"
    }
}
