//
//  DatePickerCollectionReusableView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 6/12/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DatePickerCollectionReusableView: JTACMonthReusableView {
    
    var titleColor: UIColor   =   UIColor.white
    var titleFont: UIFont     =   UIFont.systemFont(ofSize: 13.0, weight: .bold)

    @IBOutlet weak var holderStackView: UIStackView?
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        updateUI()
        holderStackView?.semanticContentAttribute = .forceLeftToRight
    }
    
    func updateUI() {
        holderStackView?.arrangedSubviews.forEach { (view) in
            (view as? UILabel)?.textColor = titleColor
            (view as? UILabel)?.font = titleFont
        }
    }
    
}
