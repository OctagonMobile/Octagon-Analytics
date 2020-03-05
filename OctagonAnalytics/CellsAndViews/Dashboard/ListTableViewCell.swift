//
//  ListTableViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = CurrentTheme.cellBackgroundColor
        titleLabel.style(CurrentTheme.bodyTextStyle())
        valueLabel.style(CurrentTheme.bodyTextStyle())
    }
    
    func setupCell(_ chart: ChartItem) {
        
        var titleText = ""
        if let rangeChartItem = chart as? RangeChartItem {
            titleText = String(format: "%d to %d",rangeChartItem.from, rangeChartItem.to)
        } else {
            titleText = "\(chart.key)"
        }

        titleLabel.text = titleText
        let value = NSNumber(value: chart.docCount).formattedWithSeparatorIgnoringDecimal
        valueLabel.text = "\(value)"
    }
}
