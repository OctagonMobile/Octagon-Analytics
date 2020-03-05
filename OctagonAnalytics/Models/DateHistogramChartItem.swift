//
//  DateHistogramChartItem.swift
//  KibanaGo
//
//  Created by Rameez on 12/6/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class DateHistogramChartItem: TermsChartItem {

    override func mapping(map: Map) {
        super.mapping(map: map)

        if let milliSecondsDateString = map["key"].currentValue as? Int {
            let timeInterval = TimeInterval( milliSecondsDateString / 1000)
            termsDate = Date(timeIntervalSince1970: timeInterval)
        }

    }
}
