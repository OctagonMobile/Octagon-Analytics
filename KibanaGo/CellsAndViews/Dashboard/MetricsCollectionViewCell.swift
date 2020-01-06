//
//  MetricsCollectionViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

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
        titleLabel.text = metric?.label
        valueLabel.text = metric?.value.formattedWithSeparatorIgnoringDecimal
    }

}

