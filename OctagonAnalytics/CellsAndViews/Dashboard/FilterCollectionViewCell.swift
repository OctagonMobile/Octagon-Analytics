//
//  FilterCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/20/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit


class FilterCollectionViewCell: UICollectionViewCell {

    public typealias FilterActionBlock = (_ sender: FilterCollectionViewCell,_ filter: FilterProtocol?) -> Void

    @IBOutlet weak var invertButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var overlayView: UIView!
    
    var removeFilterActionBlock: FilterActionBlock?
    var invertFilterActionBlock: FilterActionBlock?

    var filter: FilterProtocol? {
        didSet {
            setupCell()
        }
    }
    
    var isFilterSelected: Bool = false {
        didSet {
            setupCell()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.backgroundColor = CurrentTheme.darkBackgroundColor.withAlphaComponent(0.8)
        overlayView.backgroundColor = CurrentTheme.darkBackgroundColor
        
        titleLabel.style(CurrentTheme.subHeadTextStyle(CurrentTheme.secondaryTitleColor))
        
        containerView.layer.cornerRadius = 20.0
    }
    
    //MARK: Button Actions
    @IBAction func removeFilterButtonAction(_ sender: UIButton) {
        removeFilterActionBlock?(self, filter)
    }
    
    @IBAction func invertButtonAction(_ sender: UIButton) {
        
        filter?.isInverted = !(filter?.isInverted ?? true)

        invertButton.isSelected = (filter?.isInverted ?? true)
        overlayView.backgroundColor = (filter?.isInverted ?? true) ? CurrentTheme.filterInvertDisableColor : CurrentTheme.darkBackgroundColor

        invertFilterActionBlock?(self, filter)
    }
    
    //MARK: Private Functions
    
    private func setupCell() {
        
        invertButton.isSelected = (filter?.isInverted ?? true)
        titleLabel.text = filter?.combinedFilterValue

        let isInverted = (filter?.isInverted ?? true)
        overlayView.backgroundColor = isInverted ? CurrentTheme.filterInvertDisableColor : CurrentTheme.darkBackgroundColor
        overlayView.isHidden = !(isInverted || isFilterSelected)
    }
}
