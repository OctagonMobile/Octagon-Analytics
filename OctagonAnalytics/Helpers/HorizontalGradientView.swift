//
//  HorizontalGradientView.swift
//  KibanaGo
//
//  Created by Rameez on 2/18/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import Foundation

class HorizontalGradientView: UIView {
    
    @IBInspectable
    var startColor: UIColor = CurrentTheme.darkBackgroundColor {
        didSet { updateGradient() }
    }
    
    @IBInspectable
    var endColor: UIColor = CurrentTheme.darkBackgroundColor.withAlphaComponent(0.0) {
        didSet { updateGradient() }
    }
    
    
    @IBInspectable
    var startPoint: CGFloat = 0.2 {
        didSet { updateGradient() }
    }

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [
            startColor.cgColor,
            endColor.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: startPoint, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        backgroundColor = UIColor.clear
    }
    
    private func updateGradient() {
        semanticContentAttribute = .forceLeftToRight
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [
            startColor.cgColor,
            endColor.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: startPoint, y: 1)
    }
}
