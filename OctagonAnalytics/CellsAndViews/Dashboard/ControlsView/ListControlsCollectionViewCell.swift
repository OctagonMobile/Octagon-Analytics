//
//  ListControlsCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ListControlsCollectionViewCell: ControlsBaseCollectionViewCell {
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = CurrentTheme.enabledStateBackgroundColor
        holderView.style(.roundCorner(5.0, 1.0, CurrentTheme.cellBackgroundColor))
    }
    
    override func updateCellContent() {
        super.updateCellContent()
        guard let selectedList = (controlWidget as? ListControlsWidget)?.selectedList, selectedList.count > 0 else {
            titleLabel.text = "Select a list..."
            return }
        titleLabel.text = selectedList.compactMap({ $0.key }).joined(separator: ",")
    }
}
