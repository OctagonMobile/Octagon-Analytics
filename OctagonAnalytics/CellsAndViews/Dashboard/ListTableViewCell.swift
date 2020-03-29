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
    
    func setupCell(_ chart: ChartItem) {
        
        var titleText = ""
        if let rangeChartItem = chart as? RangeChartItem {
            titleText = String(format: "%d to %d",rangeChartItem.from, rangeChartItem.to)
        } else {
            titleText = "\(chart.key)"
        }

        valueLabel1.text = titleText
        let value = NSNumber(value: chart.docCount).formattedWithSeparatorIgnoringDecimal
        valueLabel2.text = "\(value)"
    }
    /*
     Sub Buckets Support
     Array of Strings will be passed representing the bucket and metric values
     */
    func configureCell(_ bucket: TableVizUIBucket) {
            
        var parent: TableVizUIData? = bucket
        var index = 0
        while parent != nil {
            processLabel(index: index, value: bucket.key)
            if parent?.childBucket == nil {
                index = index + 1
                processLabel(index: index, value: bucket.value)
            }
            parent = parent?.childBucket
            index = index + 1
        }
    }
    
    private func processLabel(index: Int, value: String) {
        if let label = baseStackView.viewWithTag(ListTableViewCell.TableVizRowTag + index) as? UILabel {
            label.text = value
        } else {
            let label = UILabel()
            label.style(CurrentTheme.bodyTextStyle())
            label.tag = ListTableViewCell.TableVizRowTag + index
            baseStackView.insertArrangedSubview(label, at: index)
            label.text = value
        }
    }
    
}
