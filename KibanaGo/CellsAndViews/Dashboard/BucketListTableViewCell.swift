//
//  BucketListTableViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 11/19/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class BucketListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var bucketType: BucketType = .unKnown
    var metricType: MetricType = .unKnown

    var chartItem: ChartItem? {
        didSet {
            updateCellContent()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.backgroundColor = CurrentTheme.cellBackgroundColor
        titleLabel.style(CurrentTheme.bodyTextStyle())
        valueLabel.style(CurrentTheme.bodyTextStyle())
        titleLabel.textAlignment = .left
    }

    fileprivate func updateCellContent() {
        
        if bucketType == .terms || bucketType == .dateHistogram  {
            let termsDate = (chartItem as? TermsChartItem)?.termsDateString ?? ""
            titleLabel.text = termsDate.isEmpty ? chartItem?.key : termsDate
        } else {
            titleLabel.text = chartItem?.key
        }

        let shouldShowBucketValue = (metricType == .sum || metricType == .max || metricType == .average)
        let value =  shouldShowBucketValue ? chartItem?.bucketValue : chartItem?.docCount
        if let value = value {
            valueLabel.text = NSNumber(value: value).formattedWithSeparatorIgnoringDecimal
//            valueLabel.text = "\(String(describing: value))"
        }
    }
    func updateCellContentLatest(_ title: String, value: String ) {
            
            titleLabel.text = title
            valueLabel.text = value

            //        if filter is SimpleFilter {
    //            valueLabel.text = (filter as! SimpleFilter).fieldValue
    //        }
        }
}
