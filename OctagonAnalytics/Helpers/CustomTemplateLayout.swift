//
//  CustomTemplateLayout.swift
//  OctagonAnalytics
//
//  Created by Rameez on 7/4/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import Foundation
/// This layout is used where collectionview width should be fixed and height is dynamic
class CustomTemplateLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 10
        self.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        guard let collectionView = collectionView else { return nil }
        if #available(iOS 11.0, *) {
            layoutAttributes.bounds.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        } else {
            // Fallback on earlier versions
            layoutAttributes.bounds.size.width = collectionView.frame.width - sectionInset.left - sectionInset.right
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard scrollDirection == .vertical else { return superLayoutAttributes }
        
        let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
            return layoutAttribute.representedElementCategory == .cell ? layoutAttributesForItem(at: layoutAttribute.indexPath) : layoutAttribute
        }
        return computedAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
