//
//  SavedSearchTableViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 11/13/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit
import LanguageManager_iOS

class SavedSearchTableViewCell: UITableViewCell {

    var selectedSavedSearch: SavedSearch? {
        didSet {
            setupSavedSearchCell()
        }
    }
    
    var cellLongPressBlock: SavedSearchCellLongPressBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
         super.prepareForReuse()
        // Reset
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    fileprivate func setupSavedSearchCell()  {

        let labelWidths = selectedSavedSearch?.columnsWidth ?? []
        var labels = [String: UILabel]()
        var allConstraints = [NSLayoutConstraint]()
        var horizontalConstraintsString = "H:|-\(5)-"
        
        let keys = selectedSavedSearch?.keys ?? []
        for (i, key) in keys.enumerated() {
            let labelName = "label\(i)"
            let label = UILabel()
            label.numberOfLines = 0
            label.isUserInteractionEnabled = true
            label.style(CurrentTheme.bodyTextStyle())
            label.translatesAutoresizingMaskIntoConstraints = false
            let keyPath = isSource(key) ? "_source.\(key)" : key
            if let value = (selectedSavedSearch?.data as NSDictionary?)?.value(forKeyPath: keyPath) {
                label.textAlignment = LanguageManager.shared.isRightToLeft ? .right : .left
                let isTimeStampValue = (i == 0)
                if isTimeStampValue {
                    label.text = formattedTimeStamp(value)
                } else if let valuesArray = value as? [String] {
                    label.text = valuesArray.joined(separator: " ")
                } else {
                    label.text = "\(value)"
                }

                if let fieldValue = ChartItem(JSON: ["key" : "\(value)"]) {
                    ///TODO Metric type need to be updated
                    let filter = Filter(fieldName: key, fieldValue: fieldValue, type: BucketType.terms, metricType: .unKnown)
                    let longPressGesture = SearchLongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(_:)), filter: filter)
                    label.addGestureRecognizer(longPressGesture)
                }
            } else {
                label.textAlignment = .center
                label.text = "-"
            }
            contentView.addSubview(label)
            labels[labelName] = label
            
            // add vertical constraints to label
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[\(labelName)]-10-|", options: [], metrics: nil, views: labels)
            allConstraints.append(contentsOf: verticalConstraints)
            
            // add label to horizontal VFL string
            horizontalConstraintsString += "[\(labelName)(\(labelWidths[i]))]-\(5)-"
        }
        
        horizontalConstraintsString += "|"
        // get horizontal contraints from horizontal VFL string
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat:horizontalConstraintsString, options: [], metrics: nil, views: labels)
        allConstraints.append(contentsOf:horizontalConstraints)
        
        NSLayoutConstraint.activate(allConstraints)

    }
    
    private func formattedTimeStamp(_ value: Any?) -> String {
        
        guard let dateString = value as? String else { return "\(String(describing: value))" }
        
        let date = dateString.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        return date?.toFormat("MMMM dd yyyy, HH:mm:ss.SSSZ") ?? dateString
    }
    
    @objc fileprivate func longPressGestureRecognized(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == UIGestureRecognizer.State.began, let gestureRecognizer = recognizer as? SearchLongPressGestureRecognizer, let filter = gestureRecognizer.filter else { return }
        cellLongPressBlock?(self, filter)
    }
    
    fileprivate func isSource(_ key: String) -> Bool {
        return !(key == "_index" || key == "_type" || key == "_id" || key == "_score" || key == "sort")
    }
}

class SearchLongPressGestureRecognizer: UILongPressGestureRecognizer {
    var filter : Filter?
    // any more custom variables here
    
    init(target: AnyObject?, action: Selector, filter : Filter?) {
        super.init(target: target, action: action)
        self.filter = filter
    }
}
