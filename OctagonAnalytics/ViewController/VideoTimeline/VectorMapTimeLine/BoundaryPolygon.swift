//
//  BoundaryPolygon.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/15/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import UIKit

class BoundaryPolygon: CAShapeLayer {
    var points: [CGPoint]!
    var region: WorldMapVectorRegion!
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
  
    init(with points: [CGPoint],
         region: WorldMapVectorRegion,
         strokeColor: UIColor,
         fillColor: UIColor) {
        self.points = points
        self.region = region
        super.init()
        path = createPolygon().cgPath
        lineWidth = 1
        self.strokeColor = strokeColor.cgColor
        self.fillColor = fillColor.cgColor
    }
    
    private func createPolygon() -> UIBezierPath {
        let polygon = UIBezierPath()
        for index in 0..<points.count {
            let point = points[index]
            if index == 0 {
                polygon.move(to: point)
            } else {
                polygon.addLine(to: point)
            }
        }
        polygon.close()
        return polygon
    }
    
    func animate(from fromColor: UIColor, to toColor: UIColor, speed: Double) {
        fillColor = toColor.cgColor
        let fillColorAnimation = CABasicAnimation.init(keyPath: "fillColor")
        fillColorAnimation.duration = speed
        fillColorAnimation.fromValue =  fromColor.cgColor
        fillColorAnimation.toValue = toColor.cgColor
        fillColorAnimation.autoreverses = false
        add(fillColorAnimation, forKey: "fillColor")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
