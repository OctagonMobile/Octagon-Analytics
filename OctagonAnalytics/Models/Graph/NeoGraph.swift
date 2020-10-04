//
//  NeoGraph.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit

class NeoGraph {
    
    var nodesList: [NeoGraphNode]   =   []
    var edgesList: [NeoGraphEdge]   =   []

    //MARK: Functions
    init(_ dict: [String: Any]) {
        
        guard let data = dict["data"] as? [[String: Any]] else { return }

        nodesList.removeAll()
        edgesList.removeAll()
        
        for item in data {
            guard let graphDict = item["graph"] as? [String: Any] else { return }
            let nodesArray = graphDict["nodes"] as? [[String: Any]] ?? []
            let relationshipsArray = graphDict["relationships"] as? [[String: Any]] ?? []

            let graphNodeList = nodesArray.compactMap({ NeoGraphNode($0) })
            let edges = relationshipsArray.compactMap({NeoGraphEdge($0)})
            nodesList.append(contentsOf: graphNodeList)
            edgesList.append(contentsOf: edges)
        }
    }
}


class NeoGraphNode {

    var id: String?
    
    var name: String?

    var number: String?

    var imageUrl: String?

    //MARK: Functions
    init(_ dict: [String: Any]) {
        id              =      dict["id"] as? String
        
        if let properties = dict["properties"] as? [String: Any] {
            name            =      properties["name"] as? String
            number          =      properties["number"] as? String
            imageUrl        =      properties["url"] as? String
        }
    }
}

class NeoGraphEdge {
    
    var id: String?
    var type: String?
    var startNodeId: String?
    var endNodeId: String?
    
    //MARK: Functions
    init(_ dict: [String: Any]) {
        id                  =      dict["id"] as? String
        type                =      dict["type"] as? String
        startNodeId         =      dict["startNode"] as? String
        endNodeId           =      dict["endNode"] as? String
    }
}
