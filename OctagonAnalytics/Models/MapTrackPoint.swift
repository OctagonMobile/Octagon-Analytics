//
//  MapTrackPoint.swift
//  KibanaGo
//
//  Created by Rameez on 4/3/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class MapTrackPoint: ChartItem {

    /// Timestamp
    var timestamp: Date?
    
    /// Location
    var location: CLLocation?
    
    /// User ID
    var userField: String       =       ""
    
    /// Image Icon
    var imageIconUrl: String    =       ""

    /// Returns Timestamp string in "YYYY-MM-dd HH:mm:ss.SSS" format
    var timestampString: String {
        guard let timestamp = timestamp else { return "" }
        return timestamp.toFormat("YYYY-MM-dd HH:mm:ss")
    }
    
    //MARK:
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        userField       <-  map["userID"]
        imageIconUrl    <-  map["faceUrl"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let dateString = map["timestamp"].currentValue as? String, let _date = dateFormatter.date(from: dateString) {
            timestamp = _date
        }

        if let locationString = map.JSON["location"] as? String {
            let coordinates = locationString.components(separatedBy: ",")
            guard let latString = coordinates.first, let longitudeString = coordinates.last else { return }
            let lat = CLLocationDegrees(latString) ?? 0.0
            let longitude = CLLocationDegrees(longitudeString) ?? 0.0

            location = CLLocation(latitude: lat, longitude: longitude)
        }
    }
    
    static func == (lhs: MapTrackPoint, rhs: MapTrackPoint) -> Bool {
        
        var isEqual = false
        if let lhsLocation = lhs.location?.coordinate, let rhsLocation = rhs.location?.coordinate {
            isEqual = (lhsLocation == rhsLocation)
        }
        isEqual = isEqual && (lhs.userField == rhs.userField) && (lhs.timestamp == rhs.timestamp)
        return isEqual
    }

}

class MapPath: NSObject {
    
    var mapTrackPoints: [MapTrackPoint] = []
    
    var userTraversedPathOverlays: [MapTrackingPolyline] = []
    
    var userCurrentPositionPoint: MapTrackPoint?

    var userIdentifier: String? {
        return mapTrackPoints.first?.userField
    }
    
    var color: UIColor?
    var userPathColor: UIColor?

    //MARK: Annotations
    fileprivate var pointAnnotation: UserPointAnnotation?
    fileprivate var pinAnnotationView: MapTrackingAnnotationView?

    //MARK:
    init(mapTracks: [MapTrackPoint]) {
        self.mapTrackPoints = mapTracks
        self.userCurrentPositionPoint = mapTrackPoints.first
    }
    
    func getPinAnnotation() -> MapTrackingAnnotationView? {
        
        if pointAnnotation == nil {
            pointAnnotation = UserPointAnnotation()
            pointAnnotation?.identifier = mapTrackPoints.first?.userField ?? ""
            pointAnnotation?.imageIconUrl = mapTrackPoints.first?.imageIconUrl
            pinAnnotationView = MapTrackingAnnotationView(annotation: pointAnnotation, reuseIdentifier: CellIdetifiers.pinCellId)
        }
        return pinAnnotationView
    }

}

extension MapPath {
    struct CellIdetifiers {
        static let pinCellId = "pinCellId"
    }
}


class UserPointAnnotation: MKPointAnnotation {
    var identifier: String          =   ""
    var color: UIColor              = CurrentTheme.darkBackgroundColor
    var mapTrack: MapTrackPoint?
    var imageIconUrl: String?
}


