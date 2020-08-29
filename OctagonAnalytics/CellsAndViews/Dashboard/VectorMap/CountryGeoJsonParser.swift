//
//  CountryCodeParser.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 8/17/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation

struct WorldMapVectorRegion: Equatable {
    var name: String?
    var code: String?
    var coordinatesList: [[CLLocationCoordinate2D]]   =   []
    
    init(name: String?, code: String?, polygonSet: [[[[Double]]]]) {
        self.name = name
        self.code = code
        
        for set in polygonSet {
            
            var list: [CLLocationCoordinate2D] = []
            
            for eachPolygon in set {
                for point in eachPolygon {
                    guard let lat = point.last, let long = point.first else { continue }
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    list.append(coordinate)
                }
            }
            coordinatesList.append(list)
        }
    }
    static func == (lhs: WorldMapVectorRegion, rhs: WorldMapVectorRegion) -> Bool {
        return lhs.name == rhs.name && lhs.code == rhs.code
    }
    
}

protocol CountryGeoJsonParser {
    
}

extension CountryGeoJsonParser {
    
    var geoJsonFileName: String {
        return "CountriesBoundary"
    }
    
    func readCountryGeoJson() -> [WorldMapVectorRegion] {
        var regionList = [WorldMapVectorRegion]()
        guard let path = Bundle.main.path(forResource: geoJsonFileName, ofType: "geojson") else {
            return []
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe)
            let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
            guard let countriesData = jsonData?["features"] as? [[String: Any]]  else {
                return []
            }
            
            for details in countriesData {
                
                let properties = details["properties"] as? [String: Any]
                //                let name = properties?["ADMIN"] as? String ?? ""
                //                let code = properties?["ISO_A3"] as? String ?? ""
                
                let name = properties?["name"] as? String ?? ""
                let code = details["id"] as? String ?? ""
                
                let geometry = details["geometry"] as? [String: Any]
                var coordinates = (geometry?["coordinates"] as? [[[[Double]]]]) ?? []
                
                if coordinates.count <= 0 {
                    if let list = (geometry?["coordinates"] as? [[[Double]]]) {
                        coordinates = [list]
                    }
                }
                
                guard code != "ATA" else {
                    
                    continue
                }
                
                let countryDetails = WorldMapVectorRegion(name: name, code: code, polygonSet: coordinates)
                guard countryDetails.coordinatesList.count > 0 else { continue }
                regionList.append(countryDetails)
            }
            
            return regionList
        } catch {
            return []
        }
    }
    
}
