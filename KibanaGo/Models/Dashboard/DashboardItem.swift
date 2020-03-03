//
//  DashboardItem.swift
//  KibanaGo
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftDate

class DashboardItem: NSObject, Mappable {

    /**
     Title of the dashboard.
     */
    var title               = ""
    
    /**
     ID of teh dashboard.
     */
    var id                  = ""

    /**
     Type of the dashboard.
     */
    var type                = ""

    /**
     Array of Panels, which contains details of each widgets in the dashboard.
     */
    var panels: [Panel]     = []

    /**
     Description of the dashboard.
     */
    var desc                = ""

    /**
     Dashboard time range (From).
     */
    var fromTime: String    = ""
    
    /**
     Dashboard time range (To).
     */
    var toTime: String      = ""

    /**
     Dashboard Query string.
     */
    var searchQuery         = ""

    /**
     Date picker mode. (NOTE: Server doesn't send this value)
     */
    var datePickerMode: DatePickerMode  =   .calendarPicker
    
    /**
     Selected Date String. (Generated based on the date picker mode)
     */
    var selectedDateString: String     =   ""
    
    /**
     Selected date to disaply
     */
    var displayDateString: String {
        return datePickerMode == .quickPicker ? (QuickPicker(rawValue: selectedDateString)?.localizedValue ?? selectedDateString) : selectedDateString
    }
    
    //MARK: Functions
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        title       <- map["title"]
        id          <- map["id"]
        type        <- map["type"]
        desc        <- map["description"]
        fromTime    <- map["timeFrom"]
        toTime      <- map["timeTo"]
        searchQuery <- map["searchQueryDashboard"]
        
        updateDatePickerModeAndSelectedDateString()
        
        guard let panelsJson  = map.JSON["panels"] as? [[String: Any]] else { return }

        let panelsList = panelsJson.compactMap { (json) -> Panel? in
            let panelType: String? = (json["visState"] as? [String: Any])?["type"] as? String
            var panel: Panel?
            if panelType == PanelType.metric.rawValue {
                panel = MetricPanel(JSON: json)
            } else if panelType == PanelType.tile.rawValue {
                panel = TilePanel(JSON: json)
            } else if panelType == PanelType.search.rawValue {
                panel = SavedSearchPanel(JSON: json)
            } else if panelType == PanelType.heatMap.rawValue {
                panel = HeatMapPanel(JSON: json)
            } else if panelType == PanelType.mapTracking.rawValue {
                panel = MapTrackingPanel(JSON: json)
            } else if panelType == PanelType.faceTile.rawValue {
                panel = FaceTilePanel(JSON: json)
            } else if panelType == PanelType.neo4jGraph.rawValue {
                panel = GraphPanel(JSON: json)
            } else if panelType == PanelType.inputControls.rawValue {
                panel = ControlsPanel(JSON: json)
            }  else {
                panel = Panel(JSON: json)
            }
            
            panel?.dashboardItem = self
            
            return panel
        }

        let sortedPanels:[Panel] = panelsList.sorted { (first, second) -> Bool in

            if first.row == second.row {
                return first.column <= second.column
            }
            return first.row < second.row
        }
        
        panels = sortedPanels
    }
    
    func updateDatePickerModeAndSelectedDateString() {
        // Update the selected date string & date picker mode based on fromTime/toTime
        let mappedValue = DatePickerMapper.shared.mappedPickerValueWith(fromTime, toDate: toTime)
        datePickerMode = mappedValue.0
        
        if datePickerMode == .quickPicker {
            selectedDateString = mappedValue.1?.rawValue ?? ""
        } else {
            // Should be parsed before generation
            selectedDateString = fromTime + " - " + toTime
        }
    }
    
    func updateDateRange(_ fromDate: Date?, toDate: Date?) {
        
        fromTime = fromDate?.toFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? ""
        toTime = toDate?.toFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? ""
    }
}

extension DashboardItem: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = DashboardItem(JSON: [:])
        copy?.title             = self.title
        copy?.id                = self.id
        copy?.type              = self.type
        copy?.desc              = self.desc
        copy?.fromTime          = self.fromTime
        copy?.toTime            = self.toTime
        copy?.searchQuery       = self.searchQuery
        copy?.panels            = self.panels
        copy?.datePickerMode      = self.datePickerMode
        copy?.selectedDateString  = self.selectedDateString

        return copy ?? self
//        return Swift.type(of:self).init(map: self)
    }
    
    
}
