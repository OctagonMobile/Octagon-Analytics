//
//  TermsChartItem.swift
//  KibanaGo
//
//  Created by Rameez on 11/9/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit
import ObjectMapper

class TermsChartItem: ChartItem {

    var keyAsString: String         = ""
    
    var termsDate: Date?
    
    var termsDateString: String? {
        guard let termsDate = termsDate else { return "" }
        return termsDate.toFormat("YYYY-MM-dd HH:mm:ss")
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        key             <- (map["key"], StringTransform())
        keyAsString     <- map["key_as_string"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let dateString = map["key_as_string"].currentValue as? String, let _date = dateFormatter.date(from: dateString) {
            termsDate = _date
        }
    }
    
    func dateFormat() -> String {
        return "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
    }
}

struct StringTransform: TransformType {
    
    func transformFromJSON(_ value: Any?) -> String? {
        return value.flatMap(String.init(describing:))
    }
    
    func transformToJSON(_ value: String?) -> Any? {
        return value
    }
    
}
