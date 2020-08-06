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

class WorldMapView: UIView {

    typealias WorldMapViewCompletionBlock = (_ completed: Bool,_ error: NSError?) -> Void
    typealias WorldMapViewTapBlock = (_ selectedCountryCode: String,_ countryName: String) -> Void
    typealias WorldMapViewRegionChange = (_ animated: Bool) -> Void

    var geoJsonFileName: String             =   "CountriesBoundary"

    var countryToBeHighlighted: [String]    =   []
    
    var normalColor: UIColor                =   .gray

    var highlightedColor: UIColor           =   UIColor(red: 127/255, green: 197/255, blue: 196/255, alpha: 1.0)

    var tapActionBlock: WorldMapViewTapBlock?

    var mapViewRegionChangeBlock: WorldMapViewRegionChange?

    var loadingCompleted: WorldMapViewCompletionBlock?

    @IBOutlet weak var mapView: MKMapView!
    
    var regionList: [WorldMapVectorRegion]   =   []
    var onLayout: (() -> Void)?

    //MARK:
    override init(frame: CGRect) {
        super.init(frame: frame)
        readGeoJsonFile()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        readGeoJsonFile()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapView.delegate = self
        
        addTapGestureToDetectRegionSelection()
//        refreshMapView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Laying out")
        zoomOutMapToMaximum()
        onLayout?()
    }
    
    
    private func zoomOutMapToMaximum() {
        guard let mapView = mapView else { return }
        mapView.mapType = .mutedStandard
        let region = MKCoordinateRegion(.world)
        mapView.setRegion(region, animated: true)
        
    }
    
    private func readGeoJsonFile() {
        
        guard let path = Bundle.main.path(forResource: geoJsonFileName, ofType: "geojson") else {
            loadingCompleted?(false, errorWithDesc("GeoJson File not found"))
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            guard let countriesData = jsonData?["features"] as? [[String: Any]]  else {
                loadingCompleted?(false, errorWithDesc("Invalid Data Format"))
                return
            }
            
            for details in countriesData {
                
                let properties = details["properties"] as? [String: Any]
//                let name = properties?["ADMIN"] as? String ?? ""
//                let code = properties?["ISO_A3"] as? String ?? ""
                
                let name = properties?["name"] as? String ?? ""
                let code = details["id"] as? String ?? ""

                let geometry = details["geometry"] as? [String: Any]
                var coordinates = (geometry?["coordinates"] as? [[[[Double]]]]) ?? []
                
                if coordinates.count <= 0 {
                    if let list = (geometry?["coordinates"] as? [[[Double]]]) {
                        coordinates = [list]
                    }
                }
                
                guard code != "ATA" else {
                    
                    continue
                }

                let countryDetails = WorldMapVectorRegion(name: name, code: code, polygonSet: coordinates)
                guard countryDetails.coordinatesList.count > 0 else { continue }
                regionList.append(countryDetails)
            }
        
            loadingCompleted?(true, nil)
        } catch {
            loadingCompleted?(false, errorWithDesc(error.localizedDescription))
        }
    }
    
    private func errorWithDesc(_ desc: String) -> NSError {
        return NSError(domain: "WorldMapView", code: 1, userInfo: [NSLocalizedDescriptionKey: desc])
    }
    
    private func addTapGestureToDetectRegionSelection() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_ :)))
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
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("Loaded")
    }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("Rendered")
    }
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
         print("Added Renderers")
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

struct WorldMapVectorRegion: Equatable {
    var name: String?
    var code: String?
    var coordinatesList: [[CLLocationCoordinate2D]]   =   []
    
    init(name: String?, code: String?, polygonSet: [[[[Double]]]]) {
        self.name = name
        self.code = code
        
        for set in polygonSet {
            
            var list: [CLLocationCoordinate2D] = []
            
            for eachPolygon in set {
                for point in eachPolygon {
                    guard let lat = point.last, let long = point.first else { continue }
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    list.append(coordinate)
                }
            }
            coordinatesList.append(list)
        }
    }
    static func == (lhs: WorldMapVectorRegion, rhs: WorldMapVectorRegion) -> Bool {
        return lhs.name == rhs.name && lhs.code == rhs.code
    }
    
}
