//
//  CoordinateMapViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 12/17/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import DTMHeatmap
import CoreLocation
import OctagonAnalyticsService

class CoordinateMapViewController: BaseHeatMapViewController {

    var tapGesture: UITapGestureRecognizer?

    var zoomToShowAllAnnotation: Bool   =   true
    //MARK:
    
    override func updatePanelContent() {
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)

        super.updatePanelContent()
        
        let locationsArray: [[String: Any?]] = mapPanel?.mapDetail.compactMap( {
            return ["location": $0.location, "docCount": $0.docCount]
        } ) ?? []

        drawPoints(locationsArray)
    }
    
    private func drawPoints(_ locationsArray: [[String: Any?]]) {
        
        applyOverlays(locationsArray)
        
        if locationsArray.count > 0, tapGesture == nil {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(BaseHeatMapViewController.tapGestureHandler(_:)))
            mapView.addGestureRecognizer(tapGesture!)
        }
        
        guard zoomToShowAllAnnotation else { return }
        zoomForAllOverlays(locationsArray)
    }
    
    func removeOverlays() {
        mapView.overlays.forEach { (overlay) in
            if overlay is MKCircle {
                mapView.removeOverlay(overlay)
            }
        }
    }
    
    func applyOverlays(_ locationsArray: [[String: Any?]]) {
        let mapType = (panel?.visState as? MapVisState)?.mapType ?? MapVisStateService.MapType.unknown
        var radius: CLLocationDistance = 1000
        
        if mapType == MapVisStateService.MapType.shadedCircleMarkers {
            radius = getShadedRadius()
        }
        
        let minimumValue = mapPanel?.mapDetail.min(by:  { $0.docCount < $1.docCount })?.docCount ?? 0.0
        let maximumValue = mapPanel?.mapDetail.max(by:  { $0.docCount < $1.docCount })?.docCount ?? 0.0
        let oldRange = DoubleRange(min: minimumValue, max: maximumValue)
        for item in locationsArray {
            guard let loc = item["location"] as? CLLocation else { continue }
            let value = item["docCount"] as? Double ?? 0.0
            if mapType == MapVisStateService.MapType.scaledCircleMarkers {
                radius = getScaledRadius(range: oldRange, value: value)
            }
            let circle = MKCircle(center: loc.coordinate, radius: radius)
            mapView.addOverlay(circle)
        }
    }
    
    func zoomForAllOverlays(_ locationsArray: [[String: Any?]]) {
        let allCircles = mapView.overlays.filter({ $0 is MKCircle })

        guard allCircles.count > 0 else { return }
        guard let initial = allCircles.first?.boundingMapRect else { return }

        let insets = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
        let mapRect = allCircles
            .dropFirst()
            .reduce(initial) { $0.union($1.boundingMapRect) }
        mapView.setVisibleMapRect(mapRect, edgePadding: insets, animated: true)
        zoomToShowAllAnnotation = false
        removeOverlays()
        applyOverlays(locationsArray)
    }

}

extension CoordinateMapViewController {
    override func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is DTMHeatmap {
            return DTMHeatmapRenderer(overlay: overlay)
        }
        
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor(red: 179/255, green: 136/255, blue: 45/255, alpha: 1)
            circle.fillColor = UIColor(red: 179/255, green: 136/255, blue: 45/255, alpha: 0.6)
            circle.lineWidth = 1
            return circle
        }
        
        let renderer = MKTileOverlayRenderer(overlay: overlay)
        return renderer
    }
}

extension CoordinateMapViewController {
    
    func getShadedRadius() -> CLLocationDistance {
        return getRadius(for: 35)
    }
    
    func getScaledRadius(range: DoubleRange, value: Double) -> CLLocationDistance {
        let convertedValue = convertToNewRange(value, range, DoubleRange(min: 20, max: 50))
        return getRadius(for: convertedValue)
    }
    
    func getRadius(for width: Double) -> CLLocationDistance {
        let region = mapView.convert(CGRect(x: 0, y: 0, width: width, height: width),
                                     toRegionFrom: mapView)
        let span = region.span
        let center = region.center
        
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc1.distance(from: loc2)
        let metersInLongitude = loc3.distance(from: loc4)
        let radiusInMetres = max(metersInLatitude/2.0, metersInLongitude/2.0)
        return radiusInMetres
    }
}
