//
//  VectorRegion.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/15/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import UIKit
import GoogleMaps

class VectorRegionLayer: CALayer {
    weak var mapView: GMSMapView!
    let region: WorldMapVectorRegion
    let strokeColor: UIColor
    var fillColor: UIColor
    var polygons: [BoundaryPolygon] = []
    weak var vectorBase: UIView?
    
    init(mapView: GMSMapView,
         region: WorldMapVectorRegion,
         strokeColor: UIColor,
         fillColor: UIColor,
         vectorBase: UIView) {
        self.mapView = mapView
        self.region = region
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.vectorBase = vectorBase
        super.init()
        constructPolygons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constructPolygons() {
        for list in region.coordinatesList {
            let points = list.compactMap {
                return mapView.projection.point(for: $0)
            }
           
            var anyPointInside = false
            for point in points {
                if mapView.bounds.contains(point) {
                    anyPointInside = true
                }
            }
            
            if !anyPointInside {
                continue
            }
            let polygon = BoundaryPolygon(with: points,
                                          region: region,
                                          strokeColor: strokeColor,
                                          fillColor: fillColor)
            addSublayer(polygon)
            polygons.append(polygon)
        }
    }
    
    func higlight(_ color: UIColor, speed: Double) {
        let currentColor = fillColor
        for polygon in polygons {
            polygon.animate(from: currentColor, to: color, speed: speed)
        }
        fillColor = color
    }
}
