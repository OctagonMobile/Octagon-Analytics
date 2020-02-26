//
//  ControlsBaseCollectionViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ControlsBaseCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var headerLabel: UILabel?
    
    var control: Control? {
        didSet {
            updateCellContent()
        }
    }
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel?.textColor = CurrentTheme.titleColor
    }
    
    internal func updateCellContent() {
        headerLabel?.text = control?.fieldName
    }
}
