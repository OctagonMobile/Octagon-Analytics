//
//  MetricsCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class MetricsCollectionViewCell: UICollectionViewCell {

    var metric: Metric? {
        didSet {
            updateCellContent()
        }
    }
    
    var fontSize: CGFloat   = 17.0 {
        didSet {
            valueLabel.style(CurrentTheme.textStyleWith(fontSize, weight: .regular))
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.style(CurrentTheme.bodyTextStyle())
        valueLabel.style(CurrentTheme.textStyleWith(fontSize, weight: .regular))
    }
    
    func updateCellContent() {
        titleLabel.text = metric?.computedLabel
        valueLabel.text = metric?.value.formattedWithSeparator2Decimal
    }

}

