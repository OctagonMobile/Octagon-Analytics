//
//  VectorMapContainer.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/16/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import Foundation
import ObjectMapper

struct VectorMapContainer: Mappable {

    var date: Date!
    var data: [VectorMap]!
    
    init(date: Date, data: [VectorMap]) {
        self.date = date
        self.data = data
    }
    init?(map: Map) {
        
    }
    
    
    mutating func mapping(map: Map) {
           if let dateString = map.JSON["key_as_string"] as? String {
               date = dateString.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
           }
           
           guard let aggsFields = map.JSON["aggs_Fields"] as? [String: Any],
               let buckets = aggsFields["buckets"] as? [[String : Any]] else { return }
           data = Mapper<VectorMap>().mapArray(JSONArray: buckets)
    }
}

extension VectorMapContainer {
    func reGroup(by ranges: [ClosedRange<Int>]) -> [String: [VectorMap]] {
        
        let groupedData = data.reduce([String: [VectorMap]]()) { (res, currentData) -> [String: [VectorMap]] in
            var temp = res
            let filtered = ranges.filter { $0.contains(Int(currentData.value)) }
            if let range = filtered.first {
                let rangeString = range.toString
                temp[rangeString] = (temp[rangeString] ?? []) + [currentData]
            }
            return temp
        }
        
        return groupedData
       
    }
}
