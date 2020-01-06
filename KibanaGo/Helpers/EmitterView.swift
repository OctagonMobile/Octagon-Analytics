//
//  EmitterView.swift
//  KibanaGo
//
//  Created by Rameez on 12/19/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import QuartzCore

class EmitterView: UIView {

    fileprivate let emitterLayer = CAEmitterLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func animate() {
        emitterLayer.removeFromSuperlayer()
        setup()
    }

    fileprivate func setup() {
        emitterLayer.emitterPosition = CGPoint(x: center.x, y: 0)
        emitterLayer.emitterSize = CGSize(width: bounds.size.width, height: 2)
        emitterLayer.emitterShape = CAEmitterLayerEmitterShape.line

        emitterLayer.emitterZPosition = 10

        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "KibanaGoLogo")?.cgImage

        emitterCell.birthRate = 2
        emitterCell.lifetime = 50
        emitterCell.velocity = 25
        emitterCell.emissionLongitude = (180 * (.pi / 180))
        emitterCell.emissionRange = (60 * (.pi / 180))

        
        emitterCell.scale = 0.4
        emitterCell.scaleRange = 0.3
        
        emitterLayer.emitterCells = [emitterCell]
        
        layer.addSublayer(emitterLayer)
    }
}
