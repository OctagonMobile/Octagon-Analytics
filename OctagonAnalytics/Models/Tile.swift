//
//  Tile.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

enum TileType: String {
    case unknown        = "unknown"
    case photo          = "Photo"
    case audio          = "Audio"
    case video          = "Video"
    
    var name: String {
        switch self {
        case .photo: return "PHOTO"
        case .audio: return "AUDIO"
        case .video: return "VIDEO"
        default: return "Unknown"
        }
    }
    
}

class Tile: Mappable {
    
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
    required init?(map: Map) {
        // Empty Method
    }
    
    func mapping(map: Map) {
        
        type          <- (map["type"],EnumTransform<TileType>())

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let dateString = map["timestamp"].currentValue as? String, let _date = dateFormatter.date(from: dateString) {
            timestamp = _date
        }

        thumbnailUrl            <- map["thumbnailUrl"]
        imageUrl                <- map["imageUrl"]
        videoUrl                <- map["videoUrl"]
        audioUrl                <- map["audioUrl"]
        imageHash               <- map["imageHash"]
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
            
            guard let res = result as? [AnyHashable: Any?], let parsedDict = res["result"] as? [String: Any], let hashesArray = parsedDict["hashes"] as? [String] else {
                completion(nil, error)
                return
            }
            
            completion(hashesArray, nil)
        }
    }
    
}
