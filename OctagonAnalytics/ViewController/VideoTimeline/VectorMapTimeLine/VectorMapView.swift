//
//  VectorMapView.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/15/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import UIKit
import GoogleMaps

class VectorMapView: UIView {
    var regions: [WorldMapVectorRegion] = []
    var mapView: GMSMapView!
    var regionSubLayers: [VectorRegionLayer] = []
    var highlightColor: UIColor = .gray
    var toHighlight = [String]()
    var currentSpeed = 0.5
    
    init(regions: [WorldMapVectorRegion], mapView: GMSMapView) {
        self.regions = regions
        self.mapView = mapView
        super.init(frame: mapView.frame)
        createRegions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func set(regions: [WorldMapVectorRegion], mapView: GMSMapView) {
        self.regions = regions
        self.mapView = mapView
        createRegions()
    }
    
    func createRegions() {
        guard !regions.isEmpty else {
            return
        }
        var regionLayers = [VectorRegionLayer]()
        for region in regions {
            let regionLayer = VectorRegionLayer(mapView: mapView, region: region, strokeColor: .white, fillColor: highlightColor, vectorBase: self)
            layer.addSublayer(regionLayer)
            regionLayers.append(regionLayer)
        }
        regionSubLayers = regionLayers
        layer.masksToBounds = true
    }
    
    func reset() {
        for subLayer in layer.sublayers ?? [] {
            subLayer.removeFromSuperlayer()
        }
    }
    
    func highlight(_ regions: [String: ([VectorMap], UIColor)]) {
        var highlighted = [VectorRegionLayer]()
        for (_, (vectorMaps, color)) in regions {
            regionSubLayers.forEach { (regionSubLayer) in
                let code = regionSubLayer.region.code ?? ""
                let codes = vectorMaps.map { $0.countryCode }
                if codes.contains(code) {
                    regionSubLayer.higlight(color, speed: currentSpeed)
                    highlighted.append(regionSubLayer)
                }
            }
        }
        
        regionSubLayers.forEach { (subLayer) in
            if !highlighted.contains(subLayer) {
                subLayer.higlight(.gray, speed: currentSpeed)
            }
        }
    }
}
