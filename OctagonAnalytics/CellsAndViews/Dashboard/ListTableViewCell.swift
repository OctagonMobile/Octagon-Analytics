//
//  ListTableViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

typealias TableVizRowData = [String]

class ListTableViewCell: UITableViewCell {
    static let TableVizRowTag = 700
   
    @IBOutlet weak var baseStackView: UIStackView!
    @IBOutlet weak var valueLabel1: UILabel!
    @IBOutlet weak var valueLabel2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = CurrentTheme.cellBackgroundColor
        valueLabel1.style(CurrentTheme.bodyTextStyle())
        valueLabel2.style(CurrentTheme.bodyTextStyle())
    }
}
