//
//  DashboardItem.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService
import SwiftDate

class DashboardItem: NSObject {
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
    init(_ responseModel: DashboardItemService) {
        super.init()
        self.title          =   responseModel.title
        self.id             =   responseModel.id
        self.type           =   responseModel.type
        self.desc           =   responseModel.desc
        self.fromTime       =   responseModel.fromTime
        self.toTime         =   responseModel.toTime
        self.searchQuery    =   responseModel.searchQuery
        
        let panelsList  =   responseModel.panels.compactMap { (panelService) -> Panel? in
            var panel: Panel?
            switch panelService.visState?.type {
            case .metric:   panel = MetricPanel(panelService)
            case .tile:     panel = TilePanel(panelService)
            case .search:   panel = SavedSearchPanel(panelService)
            case .heatMap:  panel = HeatMapPanel(panelService)
            case .mapTracking:  panel = MapTrackingPanel(panelService)
            case .faceTile:     panel = FaceTilePanel(panelService)
            case .neo4jGraph:   panel = GraphPanel(panelService)
            case .gauge, .goal: panel = GaugePanel(panelService)
            case .inputControls: panel = ControlsPanel(panelService)
            default: panel = Panel(panelService)
            }
            
            panel?.dashboardItem    =   self
            return panel
        }
        let sortedPanels:[Panel] = panelsList.sorted { (first, second) -> Bool in

            if first.row == second.row {
                return first.column <= second.column
            }
            return first.row <= second.row
        }

        panels = sortedPanels

        updateDatePickerModeAndSelectedDateString()
    }
    
    override init() {
        super.init()
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
        
        let copy = DashboardItem()
        copy.title             = self.title
        copy.id                = self.id
        copy.type              = self.type
        copy.desc              = self.desc
        copy.fromTime          = self.fromTime
        copy.toTime            = self.toTime
        copy.searchQuery       = self.searchQuery
        copy.panels            = self.panels
        copy.datePickerMode      = self.datePickerMode
        copy.selectedDateString  = self.selectedDateString

        return copy
    }
}
