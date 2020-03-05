//
//  ListControlsCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ListControlsCollectionViewCell: ControlsBaseCollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = CurrentTheme.enabledStateBackgroundColor
    }
    
    override func updateCellContent() {
        super.updateCellContent()
        guard let selectedList = (controlWidget as? ListControlsWidget)?.list, selectedList.count > 0 else {
            titleLabel.text = "Select a list..."
            return }
        titleLabel.text = selectedList.compactMap({ $0.key }).joined(separator: ",")
    }
}
