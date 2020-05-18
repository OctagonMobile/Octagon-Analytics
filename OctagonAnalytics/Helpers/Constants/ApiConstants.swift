//
//  ApiConstants.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 5/18/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

struct PanelConstant {
    static let id            = "id"
    static let index         = "panelIndex"
    static let row           = "row"
    static let column        = "col"
    static let width         = "size_x"
    static let height        = "size_y"
    static let searchIndex   = "searchSourceJSON.index"
    static let searchQuery   = "searchQueryPanel"
    static let visState      = "visState"
    static let type          = "type"
    static let result        = "result"
    static let searchQueryDashboard = "searchQueryDashboard"
    static let aggregations = "aggregations"
    static let tableHeaders = "tableHeaders"
    static let label = "label"
}

struct FilterConstants {
    static let filters = "filters"
    static let id    = "id"
    static let timeFrom = "timeFrom"
    static let timeTo = "timeTo"
    static let type  = "filterType"
    static let field = "filterField"
    static let value = "filterValue"
    static let rangeFrom = "filterRangeFrom"
    static let rangeTo = "filterRangeTo"
    static let inverted = "isFilterInverted"
    static let interval = "interval"
}

struct BucketConstant {
    static let docCount = "doc_count"
    static let values = "values"
    static let value = "value"
    static let bucketValue = "bucketValue"
    static let key = "key"
    static let keyAsString = "key_as_string"
    static let from = "from"
    static let to = "to"
}

struct AggregationConstant {
    static let buckets = "buckets"
}
