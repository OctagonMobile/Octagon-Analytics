//
//  FilterInfoTableViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 8/18/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit

class FilterInfoTableViewCell: UITableViewCell {

    typealias FilterCheckBoxActionBlock = (_ sender: UIButton, _ filterItem: FilterProtocol?,_ marked: Bool) -> Void

    var checkBoxActionBlock: FilterCheckBoxActionBlock?
    
    @IBOutlet var checkButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    private var filterValue: FilterProtocol?
    
    //MARK:
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.style(CurrentTheme.headLineTextStyle(CurrentTheme.secondaryTitleColor))
        valueLabel.style(CurrentTheme.headLineTextStyle(CurrentTheme.secondaryTitleColor))
    }
    
    func setup(_ filter: FilterProtocol, isIncluded: Bool) {
        
        filterValue = filter
        
        titleLabel.text = filter.fieldName
        
        if let filter = filter as? SimpleFilter {

            valueLabel.text = filter.displayValue
        } else if let filter = filter as? DateHistogramFilter {
            valueLabel.text = filter.displayValue
        }
        checkButton.isSelected = isIncluded
    }
    
    @IBAction func checkButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        checkBoxActionBlock?(sender, filterValue, sender.isSelected)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
