//
//  InputControlsVisState.swift
//  KibanaGo
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation
import ObjectMapper

class InputControlsVisState: VisState {
    
    var controls: [Control]  =  []
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        guard let params = map.JSON["params"] as? [String: Any],
        let controlsList = params["controls"] as? [[String: Any]] else {
            return
        }
        
        controls = Mapper<Control>().mapArray(JSONArray: controlsList)
        
    }
}

class Control: Mappable {
    
    enum ControlType: String {
        case range
        case list
    }

    var id: String              =   ""
    var indexPattern: String    =   ""
    var fieldName: String       =   ""
    var parent: String          =   ""
    var label: String           =   ""
    var type: ControlType       =   .range
    var rangeOptions: RangeOptions?
    var listOptions: RangeOptions?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id              <-  map["id"]
        indexPattern    <-  map["indexPattern"]
        fieldName       <-  map["fieldName"]
        parent          <-  map["parent"]
        label           <-  map["label"]
        type            <-  (map["type"],EnumTransform<ControlType>())
        
        switch type {
        case .range:
            rangeOptions        <-  map["options"]
        case .list:
            listOptions         <-  map["options"]
        }
    }
}

class RangeOptions: Mappable {
    
    var decimalPlaces: Int  =   0
    var step: Int           =   0

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        decimalPlaces   <-  map["decimalPlaces"]
        step            <-  map["step"]
    }

}

class ListOptions: Mappable {
    
    var type: BucketType        =   .unKnown
    var multiselect: Bool       =   true
    var dynamicOptions: Bool    =   true
    var size: Int               =   0
    var order: String           =   ""

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        type            <-  (map["type"],EnumTransform<BucketType>())
        multiselect     <-  map["multiselect"]
        dynamicOptions  <-  map["dynamicOptions"]
        size            <-  map["size"]
        order           <-  map["order"]
    }

}
