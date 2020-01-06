//
//  InfoView.swift
//  KibanaGo
//
//  Created by Rameez on 2/5/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts
import LanguageManager_iOS

typealias DrillDownActionBlock = (_ sender: UIButton, _ filterItem: FilterProtocol?) -> Void

class DrillDownButton: UIButton {
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                let alpha: CGFloat = CurrentTheme.isDarkTheme ? 1.0 : 0.1
                backgroundColor = CurrentTheme.lightBackgroundColor.withAlphaComponent(alpha)
                style(.roundCorner(3.0, 0.0, UIColor.clear))
            } else {
                backgroundColor = CurrentTheme.drillDownButtonBackgroundColor
                style(.roundCorner(3.0, 1.0, UIColor.white))
            }
            super.isHighlighted = newValue
        }

    }
}

class InfoView: UIView {

    @IBOutlet weak var blurrView: UIVisualEffectView!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countTitleLabel: UILabel!
    @IBOutlet weak var valueTitleLabel: UILabel!
    @IBOutlet weak var fieldTitleLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var drillDownButton: UIButton!
    
    var drillDownAction: DrillDownActionBlock?

    var selectedFilterItem: FilterProtocol?
    
    //MARK: Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialConfiguration()
    }

    //MARK: Private Functions
    private func initialConfiguration() {
        
        blurrView.isHidden = CurrentTheme.isDarkTheme
        style(.shadow(4.0, offset: CGSize(width: 0.0, height: 2.0), opacity: 1.0))
        blurrView.style(.roundCorner(4.0, 0.0, .clear))
        
        let theme = CurrentTheme
        backgroundColor = theme.darkBackgroundColorSecondary//.withAlphaComponent(0.9)
        drillDownButton.style(theme.headLineTextStyle(drillDownTitleColor))
        drillDownButton.setTitleColor(theme.secondaryTitleColor, for: .highlighted)
        drillDownButton.style(.roundCorner(3.0, 1.0, UIColor.white))
        drillDownButton.backgroundColor = CurrentTheme.drillDownButtonBackgroundColor
        let drillIconName = CurrentTheme.isDarkTheme ? "DrillDown-Dark" : "DrillDownWhite"
        drillDownButton.setImage(UIImage(named: drillIconName), for: .normal)
        
        let leftEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        let rightEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        drillDownButton.titleEdgeInsets = LanguageManager.shared.isRightToLeft ? rightEdgeInsets : leftEdgeInsets
        drillDownButton.imageEdgeInsets = LanguageManager.shared.isRightToLeft ? leftEdgeInsets : rightEdgeInsets

        fieldTitleLabel.style(theme.subHeadTextStyle(infoTitleColor))
        valueTitleLabel.style(theme.subHeadTextStyle(infoTitleColor))
        countTitleLabel.style(theme.subHeadTextStyle(infoTitleColor))

        fieldLabel.style(theme.headLineTextStyle(theme.secondaryTitleColor))
        valueLabel.style(theme.headLineTextStyle(theme.secondaryTitleColor))
        countLabel.style(theme.headLineTextStyle(theme.secondaryTitleColor))

    }
    
    //MARK: Button Action
    @IBAction func drillDownAction(_ sender: UIButton) {
        drillDownAction?(sender, selectedFilterItem)
    }
    
    //MARK: Public Functions
    func updateDetails(_ selectedItem: FilterProtocol?) {
        
        fieldLabel.text = selectedItem?.fieldName ?? ""
        selectedFilterItem = selectedItem
        
        let isDateFilter = selectedItem is DateFilter
        let metricType = isDateFilter ? (selectedItem as? DateFilter)?.metricType : (selectedItem as? Filter)?.metricType
        
        countTitleLabel.text =  metricType?.rawValue.capitalized.localiz()

        if let fieldValue = isDateFilter ? (selectedItem as? DateFilter)?.fieldValue : (selectedItem as? Filter)?.fieldValue {
            let shouldShowBucketValue = (metricType == .sum || metricType == .max || metricType == .average)
            let value = shouldShowBucketValue ? fieldValue.bucketValue : fieldValue.docCount
            countLabel.text = NSNumber(value: value).formattedWithSeparatorIgnoringDecimal
        }

        if let item = selectedItem as? DateFilter {
            updateValueForDateFilter(item)
        } else if let item = selectedItem as? Filter {
            updateValueForFilter(item)
        }

        if metricType == MetricType.unKnown {
            countTitleLabel.text = ""
            countLabel.text = ""
        }
    }
    
    private func updateValueForFilter(_ item: Filter) {
        
        if item.type == .terms {
            let termsDate = (item.fieldValue as? TermsChartItem)?.termsDateString ?? ""
            valueLabel.text = termsDate.isEmpty ? item.fieldValue.key : termsDate
        } else if item.type == .dateHistogram {
            let termsDate = (item.fieldValue as? DateHistogramChartItem)?.termsDateString ?? ""
            valueLabel.text = termsDate.isEmpty ? item.fieldValue.key : termsDate
        } else {
            valueLabel.text = item.fieldValue.key
        }
    }

    private func updateValueForDateFilter(_ item: DateFilter)  {
        
        guard let fromdate = item.calculatedFromDate, let todate = item.calculatedToDate else {
            valueLabel.text = ""
            return
        }

        var format = "dd/MM/yyyy HH:mm:ss"
        let result = fromdate.compare(toDate: todate, granularity: Calendar.Component.second)
        if result == .orderedSame {
            format = "dd/MM/yyyy HH:mm:ss.SSS"
            var rect = frame
            rect.size.width += 50
            frame = rect
            layoutIfNeeded()
        }
        
        let fromDate = fromdate.toFormat(format)
        let toDate = todate.toFormat(format)
        valueLabel.text = fromDate + " -\n" + toDate
    }
}

extension InfoView {

    var infoTitleColor: UIColor {
        switch CurrentTheme {
        case .light: return CurrentTheme.standardColor
        case .dark: return UIColor.Primary.lightStateGray
        }
    }

    var drillDownTitleColor: UIColor {
        switch CurrentTheme {
        case .light: return .white
        case .dark: return CurrentTheme.headerViewBackground
        }
    }

}
