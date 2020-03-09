//
//  DatePickerMapper.swift
//  OctagonAnalytics
//
//  Created by Rameez on 6/21/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class DatePickerMapper: NSObject {

    static let shared = DatePickerMapper()
    private var quickDatePickerMapper: [String: QuickPicker] = [ "now/d-now/d": QuickPicker.today,
                                                                  "now-1d/d-now-1d/d": QuickPicker.yesterday,
                                                                  "now-30d-now": QuickPicker.lastThirtyDays,
                                                                  "now-60d-now": QuickPicker.lastSixtyDays,
                                                                  "now-90d-now": QuickPicker.lastNintyDays,
                                                                  "now-6M-now": QuickPicker.lastSixMonths,
                                                                  "now-1y-now": QuickPicker.lastOneYear,
                                                                  "now-2y-now": QuickPicker.lastTwoYear,
                                                                  "now-5y-now": QuickPicker.lastFiveYear]

    func mappedPickerValueWith(_ fromDate: String, toDate: String) -> (DatePickerMode , QuickPicker?) {
        
        let combinedDateString = fromDate + "-" + toDate
        let mappedValue = quickDatePickerMapper[combinedDateString]
        let datePickerMode = mappedValue == nil ? DatePickerMode.calendarPicker : DatePickerMode.quickPicker
        return (datePickerMode, mappedValue)
    }
}
