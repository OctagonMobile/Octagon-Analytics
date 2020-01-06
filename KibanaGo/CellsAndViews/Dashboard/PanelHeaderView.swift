//
//  PanelHeaderView.swift
//  KibanaGo
//
//  Created by Rameez on 11/16/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class PanelHeaderView: UIView {

    @IBInspectable
    var shouldShowLegendButton: Bool = false
    
    fileprivate let label = UILabel()
    fileprivate let legendButton = UIButton(type: .custom)
    fileprivate let flipButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        label.backgroundColor = .green
        flipButton.backgroundColor = .red
        legendButton.backgroundColor = .green
        
        addSubview(label)
        addSubview(flipButton)
        
        
        var views: [String: UIView] = ["label": label, "flipButton": flipButton]

        var labelWidthPercentage: CGFloat = 0.85
        if shouldShowLegendButton {
            views["legendButton"] = legendButton

            labelWidthPercentage = 0.70
            addSubview(legendButton)
            
            let legendButtonWidthConstraint = NSLayoutConstraint(item: legendButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.15, constant: 0.0)
            addConstraint(legendButtonWidthConstraint)
            
            let horizontalConstraintFormat = "H:|-0-[label]-0-[flipButton]-0-[legendButton]-0-|"
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraintFormat, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
            addConstraints(horizontalConstraints)

            let legendButtonVerticalConstraintFormat = "V:|-0-[legendButton]-0-|"
            let legendButtonVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: legendButtonVerticalConstraintFormat, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
            addConstraints(legendButtonVerticalConstraints)

            
        } else {
            
            let horizontalConstraintFormat = "H:|-0-[label]-0-[flipButton]-0-|"
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: horizontalConstraintFormat, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
            addConstraints(horizontalConstraints)

        }
        
        // Add Vertical Constraint
        let labelVerticalConstraintFormat = "V:|-0-[label]-0-|"
        let labelVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: labelVerticalConstraintFormat, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        addConstraints(labelVerticalConstraints)

        let flipButtonVerticalConstraintFormat = "V:|-0-[flipButton]-0-|"
        let flipVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: flipButtonVerticalConstraintFormat, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        addConstraints(flipVerticalConstraints)
        

        // Add Width Constraint
        let labelWidthContraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: labelWidthPercentage, constant: 0.0)
        let flipButtonWidthConstraint = NSLayoutConstraint(item: flipButton, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.15, constant: 0.0)
        addConstraints([labelWidthContraint, flipButtonWidthConstraint])

    }
}
