//
//  WorldMapView.swift
//  WorldMapSample
//
//  Created by Rameez on 10/15/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class WorldMapView: UIView, CountryGeoJsonParser {

    typealias WorldMapViewTapBlock = (_ selectedCountryCode: String,_ countryName: String) -> Void
    typealias WorldMapViewRegionChange = (_ animated: Bool) -> Void
    
    var countryToBeHighlighted: [String]    =   []
    
    var normalColor: UIColor                =   .gray

    var highlightedColor: UIColor           =   UIColor(red: 127/255, green: 197/255, blue: 196/255, alpha: 1.0)

    var tapActionBlock: WorldMapViewTapBlock?

    var mapViewRegionChangeBlock: WorldMapViewRegionChange?

    @IBOutlet weak var mapView: MKMapView!
    
    var regionList: [WorldMapVectorRegion]   =   []
    var onLayout: (() -> Void)?

    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)
        regionList = readCountryGeoJson()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        regionList = readCountryGeoJson()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.delegate = self
        
        addTapGestureToDetectRegionSelection()
        refreshMapView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        zoomOutMapToMaximum()
        onLayout?()
    }
    
    
    private func zoomOutMapToMaximum() {
        guard let mapView = mapView else { return }
        mapView.mapType = .mutedStandard
        let region = MKCoordinateRegion(.world)
        mapView.setRegion(region, animated: true)
        
    }
    
    private func errorWithDesc(_ desc: String) -> NSError {
        return NSError(domain: "WorldMapView", code: 1, userInfo: [NSLocalizedDescriptionKey: desc])
    }
    
    private func addTapGestureToDetectRegionSelection() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action:     #selector(handleTapGesture(_ :)))
        singleTapGesture.cancelsTouchesInView = false
        mapView?.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.cancelsTouchesInView = false
        mapView?.addGestureRecognizer(doubleTapGesture)
        
        // Ignore single tap if the user actually double taps
        singleTapGesture.require(toFail: doubleTapGesture)
    }

    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        let tapPoint = tapGesture.location(in: mapView)
        let tapCoordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

        var selectedRegion: WorldMapVectorRegion?
        for polygon in mapView.overlays {
            
            guard let vectorPolygon = polygon as? WorldMapVectorPolygon, vectorPolygon.isCoordinateInsidePolyon(coordinate: tapCoordinate) else { continue }
            selectedRegion = regionList.filter({ $0.code == vectorPolygon.region?.code }).first
            break
        }

        if let code = selectedRegion?.code, let name = selectedRegion?.name {
            tapActionBlock?(code, name)
        }

    }
    
    func refreshMapView() {
        
        // Remove Overlays
        
        let filteredPolygonOverlay = mapView.overlays.filter( { $0 is WorldMapVectorPolygon })
        mapView.removeOverlays(filteredPolygonOverlay)

        // Add overlays
        for details in regionList {
            for list in details.coordinatesList {
                let polygon = WorldMapVectorPolygon(coordinates: list, count: list.count)
                polygon.region = details
                mapView.addOverlay(polygon)
            }
        }
    }
}

extension WorldMapView: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is WorldMapVectorPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = .white
            
            let code = (overlay as? WorldMapVectorPolygon)?.region?.code ?? ""
            let fillColor = countryToBeHighlighted.contains(code) ? highlightedColor : normalColor
            polygonView.fillColor = fillColor
            return polygonView
        }
        
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // Dismiss location details pop up if shown
        mapViewRegionChangeBlock?(animated)
    }
}

extension WorldMapView {
    class WorldMapVectorPolygon: MKPolygon {
        var region: WorldMapVectorRegion?
        
        func isCoordinateInsidePolyon(coordinate: CLLocationCoordinate2D) -> Bool {
            
            let polygonRenderer = MKPolygonRenderer(polygon: self)
            let currentMapPoint: MKMapPoint = MKMapPoint(coordinate)
            let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
            
            return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
}
