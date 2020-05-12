//
//  ListOptionControlsView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 5/10/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ListOptionControlsView: UIView {
    
    typealias DropDownActionBlock = (_ sender: Any) -> Void

    var listControlWidget: ListControlsWidget? {
        didSet { updateContent() }
    }
    
    var dropDownActionBlock: DropDownActionBlock?

    //MARK: Outlets
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = CurrentTheme.titleColor
        selectButton.setTitleColor(CurrentTheme.enabledStateBackgroundColor, for: .normal)
        holderView.style(.roundCorner(5.0, 1.0, CurrentTheme.standardColor))
    }
    
    func updateContent() {
        titleLabel?.text = listControlWidget?.control.fieldName

        guard let selectedList = listControlWidget?.selectedList, selectedList.count > 0 else {
            selectButton.setTitle("Select a list...", for: .normal); return
        }
        
        let text = selectedList.compactMap({ $0.key }).joined(separator: ",")
        selectButton.setTitle(text, for: .normal)
    }
    
    @IBAction func buttonTappedAction(_ sender: UIButton) {
        dropDownActionBlock?(sender)
    }
}
