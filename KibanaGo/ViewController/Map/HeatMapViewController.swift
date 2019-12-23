//
//  HeatMapViewController.swift
//  KibanaGo
//
//  Created by Rameez on 12/31/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit

class HeatMapViewController: BaseHeatMapViewController {

            
    var tapGesture: UITapGestureRecognizer?
            
    //MARK: Methods
    override func updatePanelContent() {

        super.updatePanelContent()
        
        // Handle HeatMap
        
        guard let heatMap = heatMap else { return }

        let minimumValue = mapPanel?.mapDetail.min(by:  { $0.docCount < $1.docCount })?.docCount ?? 100.0
        let maximumValue = mapPanel?.mapDetail.max(by:  { $0.docCount < $1.docCount })?.docCount ?? 110.0

        let oldRange = DoubleRange(min: minimumValue, max: maximumValue)
        let newRange = DoubleRange(min: 100, max: 1100)
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
