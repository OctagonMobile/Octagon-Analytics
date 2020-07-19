//
//  VectorMap.swift
//  VectorMapAnimation
//
//  Created by Kishore Kumar on 7/16/20.
//  Copyright © 2020 OctagonGo. All rights reserved.
//

import Foundation

struct VectorMap {
    let countryCode: String
    let value: Float
}

extension String {
    var toRange: ClosedRange<Int>? {
        let splitted = components(separatedBy: " to ")
        if let firstHalf = splitted.first,
            let lastHalf = splitted.last,
            let floor = Int(firstHalf),
            let ceil = Int(lastHalf) {
            return floor...ceil
        }
        return nil
    }
}
