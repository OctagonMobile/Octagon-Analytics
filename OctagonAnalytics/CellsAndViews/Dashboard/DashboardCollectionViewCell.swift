//
//  DashboardCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/24/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class DashboardCollectionViewCell: UICollectionViewCell {
    
    var viewController: PanelBaseViewController = PanelBaseViewController() {
        didSet {
            configureCell()
        }
    }
    
    var selectFieldAction: SelectFieldActionBlock?
    var deselectFieldAction: DeselectFieldActionBlock?
   
    var showInfoFieldActionBlock: ShowInfoFieldActionBlock?


    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func configureCell() {
        viewController.selectFieldAction = { [weak self] (sender, selectedItem, widgetRect) in
            
            guard let strongSelf = self else { return }
            strongSelf.selectFieldAction?(strongSelf, selectedItem, strongSelf.frame)
        }
        
        viewController.deselectFieldAction = { [weak self] (sender) in
            self?.deselectFieldAction?(sender)
        }
        
        viewController.showInfoFieldActionBlock = { [weak self] (sender, selectedItems, widgetRect) in
            guard let strongSelf = self else { return }
            strongSelf.showInfoFieldActionBlock?(strongSelf, selectedItems, strongSelf.frame)
        }

    }
}
