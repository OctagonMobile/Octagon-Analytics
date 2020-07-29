//
//  FaceTileViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/24/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class FaceTileViewController: PanelBaseViewController {

    var dataSource: [FaceTile] {
        return (panel as? FaceTilePanel)?.faceTileList ?? []
    }
    
    var faceTilePanel: FaceTilePanel? {
        return panel as? FaceTilePanel
    }

    @IBOutlet weak var faceTileCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        faceTileCollectionView.register(UINib(nibName: NibName.faceTileCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.faceTileCellId)
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        faceTileCollectionView.reloadData()
    }
}

extension FaceTileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.faceTileCellId, for: indexPath) as? FaceTileCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.faceTile = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedFace = dataSource[indexPath.row]
        
        guard let fieldName = faceTilePanel?.filterName, let _ = panel?.bucketType, !selectedFace.faceUrl.isEmpty else { return }
        let interval = (panel?.bucketType == BucketType.histogram) ?  panel?.bucketAggregation?.params?.intervalInt : nil
        
        let filter = SimpleFilter(fieldName: fieldName, fieldValue: "\(selectedFace.fileName)", type: BucketType.terms, interval: interval)
        if !Session.shared.containsFilter(filter) {
            selectFieldAction?(self, filter, nil)
        }
    }
}

extension FaceTileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard dataSource.count > 0 else { return CGSize.zero }
        return CGSize(width: 90, height: 90)
    }
    
}

extension FaceTileViewController {
    struct NibName {
        static let faceTileCollectionViewCell = "FaceTileCollectionViewCell"
    }
    
    struct CellIdentifiers {
        static let faceTileCellId = "faceTileCellId"
    }
}
