//
//  ControlsPanel.swift
//  OctagonAnalytics
//
//  Created by Rameez on 3/1/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import OctagonAnalyticsService

class ControlsPanel: Panel {
    
    var maxAgg: CGFloat?
    
    var minAgg: CGFloat?

    override init(_ responseModel: PanelService) {
        super.init(responseModel)
        
        guard let controlsPanelService = responseModel as? ControlsPanelService else { return }
        self.maxAgg =   controlsPanelService.maxAgg
        self.minAgg =   controlsPanelService.minAgg
    }
    
    override func requestParams() -> VizDataParamsBase? {
        
        var controlsList: [ControlsParams] = []
        
        for control in (visState as? InputControlsVisState)?.controls ?? [] {
            let controlParam = ControlsParams(control.type, indexPatternId: control.indexPattern, fieldName: control.fieldName)
            controlsList.append(controlParam)
        }
        let reqParam = ControlsVizDataParams(controlsList)
        reqParam.panelType = visState?.type ?? .unKnown
        reqParam.timeFrom = dashboardItem?.fromTime
        reqParam.timeTo = dashboardItem?.toTime
        reqParam.searchQueryPanel = searchQuery
        reqParam.searchQueryDashboard = dashboardItem?.searchQuery ?? ""
        return reqParam
    }
    /**
     Parse the data into Metrics List.
     
     - parameter result: Data to be parsed.
     - returns:  Array of Metric Object
     */
    override func parseData(_ result: Any?) -> [Any] {
        guard let responseJson = result as? [[String: Any]], visState?.type != .unKnown,
            let aggregationsDict = responseJson.first?["aggregations"] as? [String: Any] else {
                return []
        }
        
        let type = (visState as? InputControlsVisState)?.controls.first?.type
        
        if type == ControlService.ControlType.range {
            let maxAggDict = aggregationsDict["maxAgg"] as? [String: Any]
            self.maxAgg = maxAggDict?["value"] as? CGFloat
            let minAggDict = aggregationsDict["minAgg"] as? [String: Any]
            self.minAgg = minAggDict?["value"] as? CGFloat
            return [["min": self.minAgg, "max":self.maxAgg]]
        } else {
            guard let termsAggs = aggregationsDict["termsAgg"] as? [String: Any],
                let bucketsList = termsAggs["buckets"] as? [[String: Any]] else { return [] }
            
            chartContentList = bucketsList.compactMap { (dict) -> ChartContent? in
                let content = ChartContent()
                content.key         = dict["key"] as? String ?? ""
                content.docCount    = dict["doc_count"] as? Double ?? 0.0
                return content
            }
            return chartContentList
        }
    }
}
