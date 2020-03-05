//
//  NeoGraph.swift
//  KibanaGo
//
//  Created by Rameez on 11/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper

class NeoGraph: Mappable {
    
    var nodesList: [NeoGraphNode]   =   []
    var edgesList: [NeoGraphEdge]   =   []

    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        
        guard let data = map.JSON["data"] as? [[String: Any]] else { return }

        nodesList.removeAll()
        edgesList.removeAll()
        
        for item in data {
            guard let graphDict = item["graph"] as? [String: Any] else { return }
            let nodesArray = graphDict["nodes"] as? [[String: Any]] ?? []
            let relationshipsArray = graphDict["relationships"] as? [[String: Any]] ?? []

            let graphNodeList = Mapper<NeoGraphNode>().mapArray(JSONArray: nodesArray)
            let edges = Mapper<NeoGraphEdge>().mapArray(JSONArray: relationshipsArray)
            nodesList.append(contentsOf: graphNodeList)
            edgesList.append(contentsOf: edges)
        }
    }
}


class NeoGraphNode: Mappable {

    var id: String?
    
    var name: String?

    var number: String?

    var imageUrl: String?

    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id              <-      map["id"]
        name            <-      map["properties.name"]
        number          <-      map["properties.number"]
        imageUrl        <-      map["properties.url"]
    }
}

class NeoGraphEdge: Mappable {
    
    var id: String?
    var type: String?
    var startNodeId: String?
    var endNodeId: String?
    
    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id                  <-      map["id"]
        type                <-      map["type"]
        startNodeId         <-      map["startNode"]
        endNodeId           <-      map["endNode"]
    }
}
