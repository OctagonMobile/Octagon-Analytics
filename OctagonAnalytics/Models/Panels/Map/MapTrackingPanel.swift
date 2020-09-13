//
//  MapTrackingPanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 4/3/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService
import SwiftDate

class MapTrackingPanel: Panel, WMSLayerProtocol {

    /// Path Trackers - Consist of Map track of a perticular track
    var pathTrackersArray: [MapPath] = []
    
    /// List of Top "numberOfItemsToShowOnMap(50)" items based on number of locations in descending order
    var sortedTracks: [MapTrackPoint]            = []
    
    /// Is map real time.
    var isRealTime: Bool                    = false
    
    private var tracks: [MapTrackPoint]          = []
    private let numberOfItemsToShowOnMap    = 20
    
    //MARK:
    override init(_ responseModel: PanelService) {
        super.init(responseModel)
        
        guard let mapTrackingPanelService = responseModel as? MapTrackingPanelService else { return }
        self.isRealTime =   mapTrackingPanelService.isRealTime
    }
    
    /**
     Parse the data into MapTrackPoint object.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Map Track Object
     */
    
    override func parseData(_ result: Any?) -> [Any] {

        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let hitsDict = responseJson.first?["hits"] as? [String: Any],
            var hitsArray = hitsDict["hits"] as? [[String: Any]] else {
                tracks.removeAll()
                return []
        }

        // Remove track if empty data
        hitsArray = hitsArray.compactMap({ (dict) -> [String: Any]? in
            if let sourceDict = dict["_source"] as? [String: Any],
                let userField = (visState as? MapVisState)?.userField,
                let locationField = (visState as? MapVisState)?.locationField,
                let timeField = (visState as? MapVisState)?.timeField {
              
                if let userId = sourceDict[userField] as? String,
                    let time = sourceDict[timeField] as? String,
                    let location = sourceDict[locationField] as? String,
                    !userId.isEmpty && !time.isEmpty && !location.isEmpty {
                    let faceUrlField = (visState as? MapVisState)?.faceUrlField ?? ""
                    let faceUrl = sourceDict[faceUrlField] ?? ""
                    return ["userID":userId, "timestamp":time, "location": location, "faceUrl": faceUrl]
                }

            }
            return nil
        })

        // Parse all items to Tracks
        tracks.removeAll()
        for hits in hitsArray {
            let track = MapTrackPoint(data: hits)
            tracks.append(track)
        }

        // Grouping and sorting
        pathTrackersArray = groupAndSortTracks()

        // Consider only grouped items
        tracks = pathTrackersArray.flatMap({ $0.mapTrackPoints })

        // Sort Items
        sortedTracks = tracks.sorted(by: { (first, second) -> Bool in
            guard let firstDate = first.timestamp, let secondDate = second.timestamp else { return false }
            return firstDate <= secondDate
        })

        return tracks
    }
        
    //MARK: Private Functions
    
    /**
     Group the tracks by "userField" & sort them based on "timestamp".
     
     - returns:  Array of Map Track objects Array
     */
    private func groupAndSortTracks()  -> [MapPath] {
        var pathTrackerArray: [MapPath] = []
        
        let predicate = { (element: MapTrackPoint) in
            return element.userField
        }
        let categorizedTracks = Dictionary(grouping: tracks, by: predicate)

        for items in categorizedTracks {
            let trackList = items.value.sorted(by: { (first, second) -> Bool in
                guard let firstDate = first.timestamp, let secondDate = second.timestamp else { return false }
                return firstDate <= secondDate
            })

            let pathTracker = MapPath(mapTracks: trackList)

            pathTrackerArray.append(pathTracker)
        }
        
        // Sort using counts
        pathTrackerArray = pathTrackerArray.sorted(by: { $0.mapTrackPoints.count > $1.mapTrackPoints.count })
        
        // Consider only top results
        pathTrackerArray = Array(pathTrackerArray.prefix(numberOfItemsToShowOnMap))
        return pathTrackerArray
    }

}
