//
//  HeatMapViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 12/31/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class HeatMapViewController: BaseHeatMapViewController {

            
    var tapGesture: UITapGestureRecognizer?
    var isZoomed: Bool = false
            
    //MARK: Methods
    override func updatePanelContent() {

        super.updatePanelContent()
        
        // Handle HeatMap
        
        guard let heatMap = heatMap else { return }
        if !isZoomed {
            zoomToAppropriateLevel()
            isZoomed = true
        }
        let minimumValue = mapPanel?.mapDetail.min(by:  { $0.docCount < $1.docCount })?.docCount ?? 100.0
        let maximumValue = mapPanel?.mapDetail.max(by:  { $0.docCount < $1.docCount })?.docCount ?? 110.0

        let oldRange = DoubleRange(min: minimumValue, max: maximumValue)
        let newRange = DoubleRange(min: 4.5, max: 5)
        let locationsArray: [[String: Any?]] = mapPanel?.mapDetail.compactMap( {
            
            let docCount = convertToNewRange($0.docCount, oldRange, newRange)
            return ["location": $0.location, "docCount": docCount]
            
        } ) ?? []
        let parsedData = getParsedHeatMapData(locationsArray)
        heatMap.setData(parsedData)
        mapView.addOverlay(heatMap)
        
        if locationsArray.count > 0, tapGesture == nil {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(BaseHeatMapViewController.tapGestureHandler(_:)))
            mapView.addGestureRecognizer(tapGesture!)
        }
    }
    
    func zoomToAppropriateLevel() {
       let maxSpan = MKCoordinateSpan(latitudeDelta: 135.68020269231502, longitudeDelta: 131.8359359933973)
//       let minSpan = MKCoordinateSpan(latitudeDelta: 0.00033266201122472694, longitudeDelta: 0.00059856596270435602)
        
        let minLatitude: Double = mapPanel?.mapDetail.min {
            return ($0.location?.coordinate.latitude ?? 0) <  ($1.location?.coordinate.latitude ?? 0)
        }.map { return ($0.location?.coordinate.latitude ?? 0) } ?? 0
        
        let maxLatitude: Double  = (mapPanel?.mapDetail.min {
            return ($0.location?.coordinate.latitude ?? 0) >  ($1.location?.coordinate.latitude ?? 0)
        }.map { return ($0.location?.coordinate.latitude ?? 0) }) ?? 0
        
        let minLongitude: Double  = mapPanel?.mapDetail.min {
            return ($0.location?.coordinate.longitude ?? 0) <  ($1.location?.coordinate.longitude ?? 0)
        }.map { return ($0.location?.coordinate.longitude ?? 0) } ?? 0
        
        let maxLongitude: Double  = mapPanel?.mapDetail.min {
            return ($0.location?.coordinate.longitude ?? 0) >  ($1.location?.coordinate.longitude ?? 0)
        }.map { return ($0.location?.coordinate.longitude ?? 0) } ?? 0
        
        let MAP_PADDING = 1.1
        let MINIMUM_VISIBLE_LATITUDE = 1.1

        var region = MKCoordinateRegion()
        region.center.latitude = (minLatitude + maxLatitude) / 2;
        region.center.longitude = (minLongitude + maxLongitude) / 2;

        region.span.latitudeDelta = (maxLatitude - minLatitude) * MAP_PADDING;

        region.span.latitudeDelta = (region.span.latitudeDelta < MINIMUM_VISIBLE_LATITUDE)
            ? MINIMUM_VISIBLE_LATITUDE
            : region.span.latitudeDelta;

        region.span.longitudeDelta = (maxLongitude - minLongitude) * MAP_PADDING;

        if region.span.latitudeDelta > maxSpan.latitudeDelta {
            region.span.latitudeDelta = maxSpan.latitudeDelta
        }
        
        if region.span.longitudeDelta > maxSpan.longitudeDelta {
            region.span.longitudeDelta = maxSpan.longitudeDelta
        }
        
        let scaledRegion = mapView.regionThatFits(region)
        mapView.setRegion(scaledRegion, animated: false)

    }
    
    
    //MARK: Private Functions
    private func getParsedHeatMapData(_ dataList: [[String: Any?]]) -> [AnyHashable: Any] {
        var ret = [AnyHashable: Any]()
        for data in dataList {

            let weight: Double = data["docCount"] as? Double ?? 0.0

            let location: CLLocation = (data["location"] as? CLLocation) ?? CLLocation(latitude: 0.0, longitude: 0.0)
            let point: MKMapPoint = MKMapPoint(location.coordinate)
            
            guard let pointValue = NSValue(mkMapPoint: point) else { continue }
            ret[pointValue] = weight
        }
        return ret
    }
}
