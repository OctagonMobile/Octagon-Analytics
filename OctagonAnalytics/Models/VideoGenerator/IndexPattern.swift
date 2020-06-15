//
//  IndexPattern.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import ObjectMapper

class IndexPattern: Mappable, Equatable {
    var id: String              =   ""
    var title: String           =   ""
    var timeFieldName: String   =   ""
    var fields: [IPField]       =   []
    
    private var fieldsString: String          =   ""

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id              <-  map["id"]
        title           <-  map["attributes.title"]
        timeFieldName   <-  map["attributes.timeFieldName"]
        fieldsString    <-  map["attributes.fields"]
        
        let fieldsData = Data(fieldsString.utf8)
        if let fieldsList =  try? JSONSerialization.jsonObject(with: fieldsData, options: .allowFragments) as? [[String: Any]] {
            fields = Mapper<IPField>().mapArray(JSONArray: fieldsList)
        }
    }
    
    static func == (lhs: IndexPattern, rhs: IndexPattern) -> Bool {
        return lhs.id == rhs.id
    }
}

class IPField: Mappable, Equatable, Hashable {
    
    var name                =   ""
    var type                =   ""
    var count               =   0
    var scripted            =   false
    var searchable          =   false
    var aggregatable        =   false
    var readFromDocValues   =   false

    //MARK: Functions

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name                <-  map["name"]
        type                <-  map["type"]
        count               <-  map["count"]
        scripted            <-  map["scripted"]
        searchable          <-  map["searchable"]
        aggregatable        <-  map["aggregatable"]
        readFromDocValues   <-  map["readFromDocValues"]
    }
    
    static func == (lhs: IPField, rhs: IPField) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}

