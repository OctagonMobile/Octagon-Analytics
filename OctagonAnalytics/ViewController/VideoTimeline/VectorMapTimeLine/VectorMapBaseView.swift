//
//  VectorMapBaseView.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 8/10/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

class VectorMapBaseView: UIView {
   
    private let apiKey = ""

    var mapView: GMSMapView!
    private var heatmapLayer: GMUHeatmapTileLayer!
    var onLoad: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        GMSServices.provideAPIKey(apiKey)
        let camera = GMSCameraPosition.camera(withLatitude: 30, longitude: 15, zoom: kGMSMinZoomLevel)

        let gmView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        do {
          // Set the map style by passing the URL of the local file.
          if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
            gmView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          } else {
            NSLog("Unable to find style.json")
          }
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        gmView.isMyLocationEnabled = false
        gmView.delegate = self
        gmView.isBuildingsEnabled = false
        gmView.settings.zoomGestures = true
        gmView.paddingAdjustmentBehavior = .never
        self.mapView = gmView
        addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.fillSuperView()
        mapView.animate(toBearing: 0)

    }
    
    func zoomTo(_ zoomRegion: WorldMapVectorRegion,
                worldRegions: [WorldMapVectorRegion],
                onComplete: @escaping (() -> Void)) {
        let path = GMSMutablePath()
        for coords in zoomRegion.coordinatesList {
            for coord in coords {
                path.add(coord)
            }
        }
        let rectangle = GMSPolyline(path: path)
        rectangle.strokeColor = .clear
        rectangle.map = self.mapView
        let bounds = GMSCoordinateBounds(path: path)
        self.mapView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 15.0))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onComplete()
        }
        
    }
}

extension VectorMapBaseView: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }
    func mapViewSnapshotReady(_ mapView: GMSMapView) {
//        onLoad?()
    }
}
