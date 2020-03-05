//
//  DatePickerCollectionViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 6/12/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DatePickerCollectionViewCell: JTACDayCell {

    var dayLabelFont: UIFont    =   UIFont.systemFont(ofSize: 17.0) {
        didSet {
            dayLabel?.font = dayLabelFont
        }
    }
    var dayLabelcolor: UIColor  =   UIColor.white {
        didSet {
            dayLabel?.textColor = dayLabelcolor
        }
    }
    
    @IBOutlet weak var currentDateView: UIView?
    @IBOutlet weak var selectedView: UIView?
    @IBOutlet weak var dayLabel: UILabel?
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        dayLabel?.textColor = dayLabelcolor
        dayLabel?.font = dayLabelFont
        currentDateView?.layer.borderColor = dayLabelcolor.cgColor

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutIfNeeded()

        selectedView?.layer.cornerRadius =  (selectedView ?? self).frame.size.width / 2
        currentDateView?.layer.cornerRadius =  (currentDateView ?? self).frame.size.width / 2

    }
}
