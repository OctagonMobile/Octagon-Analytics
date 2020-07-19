//
//  VectorMapView.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/15/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import UIKit
import MapKit

class VectorMapView: UIView {
    var regions: [WorldMapVectorRegion]!
    var mapView: MKMapView!
    var regionSubLayers: [VectorRegionLayer] = []
    var highlightColor: UIColor = .gray
    var toHighlight = [String]()
    
    init(regions: [WorldMapVectorRegion], mapView: MKMapView) {
        self.regions = regions
        self.mapView = mapView
        super.init(frame: mapView.frame)
        layer.masksToBounds = true
        createRegions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func set(regions: [WorldMapVectorRegion], mapView: MKMapView) {
        self.regions = regions
        self.mapView = mapView
        createRegions()
    }
    
    func createRegions() {
        var regionLayers = [VectorRegionLayer]()
        for region in regions {
            let regionLayer = VectorRegionLayer(mapView: mapView, region: region, strokeColor: .white, fillColor: highlightColor)
            layer.addSublayer(regionLayer)
            regionLayers.append(regionLayer)
        }
        regionSubLayers = regionLayers
    }
    
    func highlight(_ regions: [String: ([VectorMap], UIColor)]) {
        for (_, (vectorMaps, color)) in regions {
            regionSubLayers.forEach { (regionSubLayer) in
                let code = regionSubLayer.region.code ?? ""
                let codes = vectorMaps.map { $0.countryCode }
                if codes.contains(code) {
                    regionSubLayer.higlight(color)
                }
            }
        }
    }
}
