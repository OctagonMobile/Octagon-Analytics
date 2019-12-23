//
//  QuickDatePickerCollectionViewCell.swift
//  DemoLargeRangeDatePicker
//
//  Created by Rameez on 7/1/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit

class QuickDatePickerCollectionViewCell: UICollectionViewCell {

    var highlightedColor: UIColor = .lightGray
    
    var cellBackgroundColor: UIColor = .gray {
        didSet {
            backgroundColor = cellBackgroundColor
        }
    }
    

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedColor : cellBackgroundColor
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = cellBackgroundColor        
        selectedBackgroundView?.backgroundColor = highlightedColor
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
        layer.cornerRadius = 5.0
    }
}
