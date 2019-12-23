//
//  SSCustomTemplateDataProvider.swift
//  KibanaGo
//
//  Created by Rameez on 6/12/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit

class CustomTemplateDataProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var dataSource: [SavedSearch]  =   []
    
    //MARK: UIcollectionview datasource & delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.CustomCardCell, for: indexPath) as? CustomCardCell else { return UICollectionViewCell() }
        
        let savedSearch = dataSource[indexPath.row]
        guard let sourceDict = savedSearch.data["_source"] as? [String: Any] else {
            return UICollectionViewCell() }
        
        cell.setupLayout(sourceDict)
        return cell
    }
}

extension CustomTemplateDataProvider {
    struct CellIdentifiers {
        static let CustomCardCell  =   "CustomCardCell"
    }
}
