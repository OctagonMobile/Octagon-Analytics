//
//  CustomCardCell.swift
//  KibanaGo
//
//  Created by Rameez on 7/4/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit
import EverLayout

class CustomCardCell: UICollectionViewCell {
    
    var layout : EverLayout?
    
    var labelKeys: [String]    =   ["full_name", "career", "gender", "nationality_prediction", "id", "imageUrl"]
    
    //MARK: Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layoutData = NSData(contentsOfFile: Bundle.main.path(forResource: "CustomTemplate", ofType: "json")!)
        self.layout = EverLayout(layoutData: layoutData! as Data)
        self.layout?.build(onView: self.contentView, viewEnvironment: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout(_ data: [String: Any])  {
        
        for key in labelKeys {
            if let myLabel = layout?.viewIndex.view(forKey: key) as? UILabel {
                myLabel.text = data[key] as? String ?? "-"
            } else if let imageView = layout?.viewIndex.view(forKey: key) as? UIImageView {
                imageView.image = nil
                guard let urlString = data[key] as? String else {
                    imageView.image = UIImage(named: "profileUser")
                    return
                }
                DataManager.shared.loadImage(imageUrl: urlString) { (result, error) in
                    guard error == nil else {
                        imageView.image = UIImage(named: "profileUser")
                        return
                    }
                    imageView.image = result as? UIImage
                }
            }
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutIfNeeded()
        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutAttributes.bounds.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        return layoutAttributes
    }
    
}
