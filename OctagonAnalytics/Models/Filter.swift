//
//  Filter.swift
//  OctagonAnalytics
//
//  Created by Rameez on 3/11/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import SwiftDate
import OctagonAnalyticsService

//MARK:
protocol FilterProtocol {
    var fieldName: String           { get set }
    var isInverted: Bool            { get set }
    var combinedFilterValue: String { get }
    var dataParams: [String: Any]   { get }
    
    func isEqual(_ object: Any) -> Bool
    func hasSameFieldName(_ object: Any) -> Bool
}

extension FilterProtocol {
    
    var fieldName: String {
        return ""
    }
    
    var isInverted: Bool {
        return false
    }
    
    func calculatedWidth(withConstraintedHeight: CGFloat,_ font: UIFont) -> CGFloat {
        return combinedFilterValue.width(withConstraintedHeight: withConstraintedHeight, font: font)
    }
    
    func isEqual(_ object: Any) -> Bool {
        return false
    }
    
    func hasSameFieldName(_ object: Any) -> Bool {
        guard let obj = (object as? FilterProtocol) else { return false }
        return fieldName == obj.fieldName
    }
}

struct ImageFilter: FilterProtocol {

    /// ID is used just to identify that this is Image filter
    var id: String     =       Constant.imageFilterId
    var fieldName: String
    var fieldValue: [String]
    var isInverted: Bool

    var combinedFilterValue: String {
        return "Image Search Filters"
    }
    
    var dataParams: [String : Any] {
        return [FilterConstants.type : "terms",
        FilterConstants.field : fieldName,
        FilterConstants.value : fieldValue,
        FilterConstants.inverted: isInverted]
    }
    
    init(fieldName: String, fieldValue: [String]) {
        self.fieldName  = fieldName
        self.fieldValue = fieldValue
        self.id         = Constant.imageFilterId
        self.isInverted = false
    }

    func isEqual(_ object: Any) -> Bool {
        return id == (object as? ImageFilter)?.id
    }
}

extension ImageFilter {
    struct Constant {
        static let imageFilterId = "ImageFilter"
    }
}

struct MapFilter: FilterProtocol {
    var isInverted: Bool
    var fieldName: String
    var fieldValue: String
    var combinedFilterValue: String {
        return "\(fieldName): \(fieldValue)"
    }
    
    var dataParams: [String : Any] {
        return [FilterConstants.type: "terms",
                FilterConstants.field: fieldName,
                FilterConstants.value: fieldValue,
                FilterConstants.inverted: isInverted]
    }
    
    init(fieldName: String, fieldValue: String) {
        self.fieldName  = fieldName
        self.fieldValue = fieldValue
        self.isInverted = false
    }
    
    func isEqual(_ object: Any) -> Bool {
        guard let obj = (object as? MapFilter) else { return false }
        return fieldName == obj.fieldName && fieldValue == obj.fieldValue
    }
    
}
struct LocationFilter: FilterProtocol {
    
    struct CoordinateRectangle {
        var topLeft: CLLocationCoordinate2D
        var topRight: CLLocationCoordinate2D
        var bottomLeft: CLLocationCoordinate2D
        var bottomRight: CLLocationCoordinate2D
        
        
        static func == (lhs: CoordinateRectangle, rhs: CoordinateRectangle) -> Bool {
            return lhs.topLeft == rhs.topLeft &&
            lhs.topRight == rhs.topRight &&
            lhs.bottomLeft == rhs.bottomLeft &&
            lhs.bottomRight == rhs.bottomRight
        }
    }


    var isInverted: Bool
    
    var fieldName: String
    
    var type: BucketType

    var coordinateRectangle: CoordinateRectangle

    var combinedFilterValue: String {
        
        return "\(fieldName): {lat: \(coordinateRectangle.topLeft.latitude), lon: \(coordinateRectangle.topLeft.longitude)} to {lat: \(coordinateRectangle.bottomRight.latitude), lon: \(coordinateRectangle.bottomRight.longitude)}"
    }
    
    var dataParams: [String : Any] {
        return [FilterConstants.type: type.rawValue,
                FilterConstants.inverted: isInverted,
                  FilterConstants.field: fieldName,
                  FilterConstants.value: ["top_left": ["lat": coordinateRectangle.topLeft.latitude, "lon": coordinateRectangle.topLeft.longitude],
            "top_right": ["lat": coordinateRectangle.topRight.latitude, "lon": coordinateRectangle.topRight.longitude],
            "bottom_left": ["lat": coordinateRectangle.bottomLeft.latitude, "lon": coordinateRectangle.bottomLeft.longitude],
            "bottom_right": ["lat": coordinateRectangle.bottomRight.latitude, "lon": coordinateRectangle.bottomRight.longitude]]
        ]

    }
    
    //MARK:
    init(fieldName: String, type: BucketType, rectangle: CoordinateRectangle) {
        self.fieldName = fieldName
        self.type = type
        self.isInverted = false
        coordinateRectangle = rectangle
    }
    
    func isEqual(_ object: Any) -> Bool {
        guard let filter = object as? LocationFilter else { return false }
        return fieldName == filter.fieldName &&
        (coordinateRectangle == filter.coordinateRectangle)
    }
}

struct SimpleFilter: FilterProtocol {
    
    var isInverted: Bool
    var fieldName: String
    var fieldValue: String
    var bucketType: BucketType
    var interval: Int?
    var combinedFilterValue: String {
        switch bucketType {
        case .histogram:
            let fVal = Int(fieldValue) ?? 0
            return "\(fieldName):\"\(fieldValue) to \(fVal + (interval ?? 0))\""
        default:
             return "\(fieldName): \(displayValue)"
        }
       
    }
    
    var displayValue: String {
        return fieldValue
    }
    
    var dataParams: [String : Any] {
        var params: [String: Any] = [:]
        params[FilterConstants.type] = bucketType.rawValue
        params[FilterConstants.field] = fieldName
        params[FilterConstants.inverted] = isInverted
        switch bucketType {
        case .range:
            let ranges: [String] = fieldValue.components(separatedBy: "-")
            params[FilterConstants.rangeFrom] = ranges.first ?? ""
            params[FilterConstants.rangeTo] = ranges.last ?? ""
        case .histogram:
                //For Histogram use Range
                let fVal = Int(fieldValue) ?? 0
                let interval = self.interval ?? 0
                params = [FilterConstants.type: "range",
                          FilterConstants.field: fieldName,
                          FilterConstants.rangeFrom: "\(fieldValue)",
                          FilterConstants.rangeTo: "\(fVal + interval)"]
        default:
            params[FilterConstants.value] = fieldValue
        }
        return params
    }
    
    init(fieldName: String, fieldValue: String, type: BucketType, interval: Int? = nil) {
        self.fieldName  = fieldName
        self.fieldValue = fieldValue
        self.bucketType = type
        self.isInverted = false
        self.interval   = interval
    }
    
    func isEqual(_ object: Any) -> Bool {
        guard let obj = (object as? SimpleFilter) else { return false }
        return fieldName == obj.fieldName && fieldValue == obj.fieldValue
    }
}

struct DateHistogramFilter: FilterProtocol {
    
    var calculatedFromDate: Date? {
        guard let keyValue = Int(fieldValue) else { return nil }
        return Date(milliseconds: keyValue)
    }

    var calculatedToDate: Date? {
        return self.dateForIntervalType(interval)
    }

    var displayValue: String {
        return (calculatedFromDate?.toFormat("YYYY-MM-dd HH:mm:ss") ?? "") +
            " to " +
            (calculatedToDate?.toFormat("YYYY-MM-dd HH:mm:ss") ?? "")
    }
    
    var dataParams: [String : Any] {
        return [:]
    }
    
    var fieldName: String
    var fieldValue: String
    var bucketType: BucketType
    var interval: AggregationParamsService.IntervalType
    var customInterval: String
    var selectedDateComponants: DateComponents?
    
    //////////
    var isInverted: Bool = false
    var combinedFilterValue: String { return "" }
    /////////

    init(fieldName: String, fieldValue: String, type: BucketType, interval: AggregationParamsService.IntervalType, customInterval: String = "", selectedComponants: DateComponents?) {
        self.fieldName  = fieldName
        self.fieldValue = fieldValue
        self.bucketType = type
        self.interval   = interval
        self.customInterval = customInterval
        self.selectedDateComponants = selectedComponants
    }
    
    func isEqual(_ object: Any) -> Bool {
        guard let obj = (object as? DateHistogramFilter) else { return false }
        return fieldName == obj.fieldName && fieldValue == obj.fieldValue
    }

    private func dateForIntervalType(_ interval: AggregationParamsService.IntervalType, value: Int = 1) -> Date? {
        guard let fromDate = calculatedFromDate else { return nil }
        
        switch interval {
        case .auto:
            return toDateForAutoInterval()
        case .millisecond:
            return fromDate + value.seconds
        case .second:
            return fromDate + value.seconds
        case .minute:
            return fromDate + value.minutes
        case .hourly:
            return (fromDate + value.hours)
        case .daily:
            return fromDate + value.days
        case .weekly:
            return fromDate + value.weeks
        case .monthly:
            return fromDate + value.months
        case .yearly:
            return fromDate + value.years
        case .custom:
            return dateForCustomInterval()
        default:
            return nil
        }
        
    }
    
    private func dateForCustomInterval() -> Date? {
        
        guard let matchedType = AggregationParamsService.IntervalType.customTypes.filter( { customInterval.contains($0.rawValue) } ).first else { return calculatedFromDate }
        let value = customInterval.replacingOccurrences(of: matchedType.rawValue, with: "")
        
        guard let intervalValue = Int(value) else { return calculatedFromDate }
        return dateForIntervalType(matchedType, value: intervalValue)
    }
    
    private func toDateForAutoInterval() -> Date? {

        guard let fromDate = calculatedFromDate else { return nil }

        // Rules for 'Auto' Date calculation
        // if greater than 1 year : yearly
        let year = selectedDateComponants?.year
        let month = selectedDateComponants?.month
        let week = selectedDateComponants?.weekOfMonth
        let days = selectedDateComponants?.day
        let hour = selectedDateComponants?.hour
        let minutes = selectedDateComponants?.minute
        let seconds = selectedDateComponants?.second

        if let year = year, year > 1 {
            return fromDate + 1.years
        }

        // if less than 1 year & greater than 6 months: monthly
        if let year = year, let month = month,
            year == 1 || (year <= 1 && month > 6) {
            return fromDate + 1.months
        }

        // if less than or equal to 6 months & greater than or equals to 1 month: weekly
        if let month = month,
            month <= 6 && month >= 1 {
            return fromDate + 1.weeks
        }

        if let week = week,
            week <= 5 && week >= 1  {
            return fromDate + 1.days
        }

        if let days = days,
            days <= 7 && days >= 1  {
            return fromDate + 12.hours
        }

        if let hour = hour,
            hour <= 24 && hour > 1 {
            return fromDate + 1.hours
        }


        if let hour = hour, let minutes = minutes,
            hour == 1 || (hour < 1 && minutes >= 10) {
            return fromDate + 5.minutes
        }

        if let minutes = minutes,
            minutes <= 10 && minutes > 0 {
            return fromDate + 10.seconds
        }

        var millisecondsToAdd = 200
        if let seconds = seconds, seconds <= 0 {
            millisecondsToAdd   =   10
        }

        let toDateMs = fromDate.millisecondsSince1970 + Int64(millisecondsToAdd)
        return Date(milliseconds: Int(truncatingIfNeeded: toDateMs))
    }


}

struct ControlsFilter: FilterProtocol {
    
    var fieldName: String
            
    var fieldValue: [String]

    var bucketType: BucketType

    var isInverted: Bool

    var combinedFilterValue: String {
        let val = fieldValue.joined(separator: ",")
        return "\(fieldName): \(val)"
    }
    
    var dataParams: [String : Any] {
        let params: [String: Any] =
            [FilterConstants.type : bucketType.rawValue,
             FilterConstants.field : fieldName,
             FilterConstants.value : fieldValue,
             FilterConstants.inverted: isInverted]
        return params
    }

    init(fieldName: String, fieldValue: [String], type: BucketType) {
        self.fieldName  = fieldName
        self.fieldValue = fieldValue
        self.isInverted = false
        self.bucketType = type
    }
    
    func isEqual(_ object: Any) -> Bool {
        guard let obj = (object as? ControlsFilter) else { return false }
        return fieldName == obj.fieldName && fieldValue == obj.fieldValue
    }
}
