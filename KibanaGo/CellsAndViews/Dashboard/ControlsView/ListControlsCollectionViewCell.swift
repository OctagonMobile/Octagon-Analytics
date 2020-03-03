//
//  ListControlsCollectionViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ListControlsCollectionViewCell: ControlsBaseCollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func updateCellContent() {
        super.updateCellContent()
        guard let selectedList = (controlWidget as? ListControlsWidget)?.selectedList else { return }
        titleLabel.text = selectedList.compactMap({ $0.key }).joined(separator: ",")
    }
}
