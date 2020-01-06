//
//  ListTableHeaderView.swift
//  KibanaGo
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import LanguageManager_iOS

typealias ButtonActionBlock = (_ sender: UIButton) -> Void

class ListTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var leftHolderView: UIView!
    @IBOutlet weak var rightHolderView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var leftArrowImageView: UIImageView!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    @IBOutlet weak var leftArrowWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightArrowWidthConstraint: NSLayoutConstraint!
    
    var leftAction: ButtonActionBlock?
    var rightAction: ButtonActionBlock?

    var arrowUpIcon: String {
        return CurrentTheme.isDarkTheme ? "ArrowUp-Dark" : "ArrowUp"
    }
    
    var arrowDownIcon: String {
        return CurrentTheme.isDarkTheme ? "ArrowDown-Dark" : "ArrowDown"
    }
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = CurrentTheme.cellBackgroundColorPair.last?.withAlphaComponent(1.0)
        
        leftButton.style(CurrentTheme.headLineTextStyle())
        rightButton.style(CurrentTheme.headLineTextStyle())
        
        let edgeInset = LanguageManager.shared.isRightToLeft ? UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        leftButton.titleEdgeInsets = edgeInset
        rightButton.titleEdgeInsets = edgeInset

        rightArrowWidthConstraint.constant  =  0
        leftArrowWidthConstraint.constant  =  0

    }
    
    func setupHeader(_ leftText: String?, _ rightText: String?,_ selectedSort: SortTable = SortTable.defaultSort) {
        leftButton.setTitle(leftText, for: .normal)
        rightButton.setTitle(rightText, for: .normal)
        

        guard selectedSort.sort != .unknown else { return }
        
        let image = selectedSort.type == .asc ?  UIImage(named: arrowUpIcon) :  UIImage(named: arrowDownIcon)

        if selectedSort.sort == .left {
            leftArrowImageView.image    = image
            rightArrowImageView.image   = nil
            
            leftArrowWidthConstraint.constant  =  25
            rightArrowWidthConstraint.constant  =  0
            
            leftHolderView.backgroundColor = CurrentTheme.headerViewBackground
            rightHolderView.backgroundColor = .clear
            
            leftButton.style(CurrentTheme.headLineTextStyle())
            rightButton.style(CurrentTheme.calloutTextStyle(CurrentTheme.disabledStateBackgroundColor))

        } else {
            leftArrowImageView.image    = nil
            rightArrowImageView.image   = image

            leftArrowWidthConstraint.constant  =  0
            rightArrowWidthConstraint.constant  =  25

            leftHolderView.backgroundColor = .clear
            rightHolderView.backgroundColor = CurrentTheme.headerViewBackground
            
            leftButton.style(CurrentTheme.calloutTextStyle(CurrentTheme.disabledStateBackgroundColor))
            rightButton.style(CurrentTheme.headLineTextStyle())

        }
        

    }
    
    @IBAction func leftButtonAction(_ sender: UIButton) {
        leftAction?(sender)
    }
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        rightAction?(sender)
    }
}
