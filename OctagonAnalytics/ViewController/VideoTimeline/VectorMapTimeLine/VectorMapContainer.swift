//
//  VectorMapContainer.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/16/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import Foundation
import OctagonAnalyticsService

struct VectorMapContainer {

    var date: Date!
    var data: [VectorMap]!
    
    //MARK: Functions
    init(_ responseModel: VideoContentService) {
        self.date = responseModel.date
        self.data = responseModel.entries.compactMap({ VectorMap($0) })
    }
    
    init(date: Date, data: [VectorMap]) {
        self.date = date
        self.data = data
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
