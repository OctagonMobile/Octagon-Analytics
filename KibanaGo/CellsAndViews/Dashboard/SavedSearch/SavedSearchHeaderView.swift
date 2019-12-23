//
//  SavedSearchHeaderView.swift
//  KibanaGo
//
//  Created by Rameez on 11/16/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit

class SavedSearchHeaderView: UITableViewHeaderFooterView {

    var headerBackgroundView: UIView? {
        return viewWithTag(100)
    }
    
    var selectedSavedSearch: SavedSearch? {
        didSet {
            setupSavedSearchCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        headerBackgroundView?.backgroundColor = CurrentTheme.cellBackgroundColorPair.last?.withAlphaComponent(1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
        headerBackgroundView?.subviews.forEach{ $0.removeFromSuperview() }
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
            label.numberOfLines = 2
            label.text = key
            label.style(CurrentTheme.headLineTextStyle())
            label.translatesAutoresizingMaskIntoConstraints = false

            headerBackgroundView?.addSubview(label)
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
}
