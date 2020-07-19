//
//  VectorMapContainer.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/16/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import Foundation

struct VectorMapContainer {
    let date: String
    let data: [VectorMap]
}

extension VectorMapContainer {
    func reGroup(by ranges: [ClosedRange<Int>]) -> [String: [VectorMap]] {

        let groupedData = data.reduce([String: [VectorMap]]()) { (res, currentData) -> [String: [VectorMap]] in
            var temp = res
            let filtered = ranges.filter { $0.contains(Int(currentData.value)) }
            if let range = filtered.first,
                let floor = range.first,
                let ceil = range.last {
               let rangeString = "\(floor) to \(ceil)"
                temp[rangeString] = (temp[rangeString] ?? []) + [currentData]
            }
            return temp
        }
        
        return groupedData
       
    }
}
