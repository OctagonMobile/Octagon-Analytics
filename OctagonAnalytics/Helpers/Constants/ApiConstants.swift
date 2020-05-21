//
//  ApiConstants.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 5/18/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

typealias PanelConstant = ApiConstant.Panel
typealias FilterConstants = ApiConstant.Filter
typealias BucketConstant = ApiConstant.Bucket
typealias AggregationConstant = ApiConstant.Aggregation
typealias MetricConstant = ApiConstant.Metric
typealias TileConstant = ApiConstant.Tile
typealias FaceTileConstant = ApiConstant.FaceTile
typealias MapDetailsConstant = ApiConstant.MapDetails

struct ApiConstant {
    
    struct Panel {
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

    struct Filter {
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

    struct Bucket {
        static let docCount = "doc_count"
        static let values = "values"
        static let value = "value"
        static let bucketValue = "bucketValue"
        static let key = "key"
        static let keyAsString = "key_as_string"
        static let from = "from"
        static let to = "to"
        static let type = "type"
    }

    struct Aggregation {
        static let buckets = "buckets"
    }

    struct Metric {
        static let type = "type"
        static let label = "label"
        static let value = "value"
    }
    
    struct Tile {
        static let thumbnailUrl = "thumbnailUrl"
        static let imageUrl = "imageUrl"
        static let videoUrl = "videoUrl"
        static let audioUrl = "audioUrl"
        static let imageHash = "imageHash"
        static let timestamp = "timestamp"
        static let type = "type"
        static let result = "result"
        static let hashes = "hashes"
    }
    
    struct FaceTile {
        static let fileName = "fileName"
        static let faceUrl = "faceUrl"
    }
    
    struct MapDetails {
        static let location = "location"
        static let lat = "lat"
        static let long = "lon"
    }
}


