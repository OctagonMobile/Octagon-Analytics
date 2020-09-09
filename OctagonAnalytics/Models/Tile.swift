//
//  Tile.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService
import Alamofire

class Tile {
    
    var type: TileType          = .unknown
    var timestamp: Date?
    var thumbnailUrl: String    = ""
    var imageUrl: String        = ""
    var videoUrl: String        = ""
    var audioUrl: String        = ""
    var imageHash: String = ""
    
    var thumbnailImage: UIImage?

    var timestampString: String? {
        guard let timestamp = timestamp else { return "" }
        return timestamp.toFormat("YYYY-MM-dd HH:mm:ss")
    }

    //MARK: Functions
    init(_ dict: [String: Any]) {
        if let tileType = dict[TileConstant.type] as? String {
            type    =   TileType(rawValue: tileType) ?? .unknown
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let dateString = dict[TileConstant.timestamp] as? String, let _date = dateFormatter.date(from: dateString) {
            timestamp = _date
        }

        thumbnailUrl            = dict[TileConstant.thumbnailUrl] as? String ?? ""
        imageUrl                = dict[TileConstant.imageUrl] as? String ?? ""
        videoUrl                = dict[TileConstant.videoUrl] as? String ?? ""
        audioUrl                = dict[TileConstant.audioUrl] as? String ?? ""
        imageHash               = dict[TileConstant.imageHash] as? String ?? ""
    }
        
    func loadImageHashesFor(_ panel: TilePanel, _ completion: @escaping CompletionBlock) {
        
        
        guard !imageHash.isEmpty else {
            let error = NSError(domain: AppName, code: 101, userInfo: [NSLocalizedDescriptionKey: "Search image isn't available for the selected image.\n(Missing Image Hash)"])
            completion(nil, error)
            return
        }
        
        let search = "/search/" + imageHash
        var containerId = "/container/"
        var maxDistance = "/distance/"
        if let visState = panel.visState as? TileVisState {
            containerId += "\(visState.containerId)"
            maxDistance += "\(visState.maxDistance)"
        }

        let url = Configuration.shared.imageHashBaseUrl + containerId + search + maxDistance
        DataManager.shared.loadData(url: url, encoding: JSONEncoding.default, parameters: nil) { (result, error) in
            
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let res = result as? [AnyHashable: Any?], let parsedDict = res[TileConstant.result] as? [String: Any], let hashesArray = parsedDict[TileConstant.hashes] as? [String] else {
                completion(nil, error)
                return
            }
            
            completion(hashesArray, nil)
        }
    }
    
}
