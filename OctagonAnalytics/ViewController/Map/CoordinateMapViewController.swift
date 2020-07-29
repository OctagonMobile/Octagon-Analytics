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
        
        let currentZoomLevel = mapView.getZoom()
        let mapType = (panel?.visState as? MapVisState)?.mapType ?? MapVisStateService.MapType.unknown
        var radius: CLLocationDistance = 1000
        
        if mapType == MapVisStateService.MapType.shadedCircleMarkers {
            radius = radiusForShadedCircleMarkers(currentZoomLevel)
        }
        
        let minimumValue = mapPanel?.mapDetail.min(by:  { $0.docCount < $1.docCount })?.docCount ?? 0.0
        let maximumValue = mapPanel?.mapDetail.max(by:  { $0.docCount < $1.docCount })?.docCount ?? 0.0
        let oldRange = DoubleRange(min: minimumValue, max: maximumValue)

        for item in locationsArray {
            guard let loc = item["location"] as? CLLocation else { continue }
            let value = item["docCount"] as? Double ?? 0.0
            if mapType == MapVisStateService.MapType.scaledCircleMarkers {
                radius = radiusForScaledCircleMarkers(currentZoomLevel, value: value, oldRange: oldRange)
            }

            let circle = MKCircle(center: loc.coordinate, radius: radius)
            mapView.addOverlay(circle)
        }
        
        if locationsArray.count > 0, tapGesture == nil {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(BaseHeatMapViewController.tapGestureHandler(_:)))
            mapView.addGestureRecognizer(tapGesture!)
        }
        
        guard zoomToShowAllAnnotation else { return }
        zoomForAllOverlays()
    }
    
    func zoomForAllOverlays() {
        let allCircles = mapView.overlays.filter({ $0 is MKCircle })

        guard allCircles.count > 0 else { return }
        guard let initial = allCircles.first?.boundingMapRect else { return }

        let insets = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
        let mapRect = allCircles
            .dropFirst()
            .reduce(initial) { $0.union($1.boundingMapRect) }
        mapView.setVisibleMapRect(mapRect, edgePadding: insets, animated: true)
        zoomToShowAllAnnotation = false
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
    
    fileprivate func radiusForShadedCircleMarkers(_ zoomLevel: Double) -> CLLocationDistance {
        var radius: CLLocationDistance = 1000
        switch zoomLevel {
        case 0...1.3:
            radius = 15000
        case 1.3...5.2:
            radius = 12000
        case 5.2...7.8:
            radius = 10000
        case 7.8...11.7:
            radius = 4000
        case 11.7...14.3:
            radius = 700
        case 14.3...16.9:
            radius = 100
        case 16.9...20.0:
            radius = 50
        default:
            radius = 1000
        }
        return radius
    }
    
    fileprivate func radiusForScaledCircleMarkers(_ zoomLevel: Double, value: Double, oldRange: DoubleRange) -> CLLocationDistance {
        
        var newRange = DoubleRange(min: 100, max: 1000)
        switch zoomLevel {
        case 0...1.3:
            newRange = DoubleRange(min: 12000, max: 15000)
        case 1.3...5.2:
            newRange = DoubleRange(min: 8000, max: 12000)
        case 5.2...7.8:
            newRange = DoubleRange(min: 5000, max: 8000)
        case 7.8...11.7:
            newRange = DoubleRange(min: 2000, max: 5000)
        case 11.7...14.3:
            newRange = DoubleRange(min: 700, max: 2000)
        case 14.3...16.9:
            newRange = DoubleRange(min: 100, max: 700)
        case 16.9...20.0:
            newRange = DoubleRange(min: 50, max: 100)
        default:
            newRange = DoubleRange(min: 100, max: 1000)
        }

        let newValue = convertToNewRange(value, oldRange, newRange)
        return newValue
    }
}
