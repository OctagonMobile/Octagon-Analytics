//
//  Canvas.swift
//  KibanaGo
//
//  Created by Rameez on 11/4/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import ObjectMapper

class Canvas: NSObject, Mappable {
    
    /**
     Title of the dashboard.
     */
    var name                =   ""
    
    /**
     ID of teh dashboard.
     */
    var id                  =   ""
    
    var pages: [CanvasPage] =   []

    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name    <-  map["attributes.name"]
        id      <-  map["id"]
        
        
        if let attributes = map.JSON["attributes"] as? [String: Any],
            let pageList = attributes["pages"] as? [[String: Any]] {
            pages   = Mapper<CanvasPage>().mapArray(JSONArray: pageList)
        }
    }

}

class CanvasPage: NSObject, Mappable {
    
    var pageId: String?

    required init?(map: Map) {}
    
    func mapping(map: Map) {
        pageId      <-  map["id"]
    }
}
