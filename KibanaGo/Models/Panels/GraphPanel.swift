//
//  GraphPanel.swift
//  KibanaGo
//
//  Created by Rameez on 11/14/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class GraphPanel: Panel {

    var graphData: NeoGraph?
    
    /**
     Loads Grpah content.
     
     - parameter completion: Call back once the server returns the response.
     */
    func loadGraphData(_ completion: CompletionBlock?) {
        
        let urlComponent = UrlComponents.graphUrlComponent
        
        var params = dataParams()
        params?["query"] = (visState as? GraphVisState)?.query
        
        DataManager.shared.loadData(urlComponent, methodType: .post, encoding: JSONEncoding.default, parameters: params) { [weak self] (result, error) in
            
            guard error == nil else {
                self?.resetDataSource()
                completion?(nil, error)
                return
            }
            
            guard let res = result as? [AnyHashable: Any?], let finalResult = res["result"], let parsedData = self?.parseGraphData(finalResult) else {
                self?.resetDataSource()
                let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: SomethingWentWrong])
                completion?(nil, error)
                return
            }
            completion?(parsedData, error)
        }
    }
    
    fileprivate func parseGraphData(_ result: Any?) -> NeoGraph? {
        guard let responseJson = result as? [String: Any], visState?.type != .unKnown,
            let remappedDict = responseJson["remapped"] as? [String: Any], let mappedData = remappedDict["data"] as? [String: Any],
            let data = (mappedData["results"] as? [[String: Any]])?.first else {
                return nil
        }
        
        graphData = NeoGraph(JSON: data)
        return graphData
    }
    
    override func resetDataSource() {
        super.resetDataSource()
        graphData = nil
    }
        
}

extension GraphPanel {
    struct UrlComponents {
        static let graphUrlComponent = "neo4j/_search"
    }
}
