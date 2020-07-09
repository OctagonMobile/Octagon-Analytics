//
//  VideoContent.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//
import ObjectMapper
import BarChartRace

class VideoContent: Mappable {
    var date: Date?
    var entries: [VideoEntry]   =   []

    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        if let dateString = map.JSON["key_as_string"] as? String {
            date = dateString.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        }
        
        guard let aggsFields = map.JSON["aggs_Fields"] as? [String: Any],
            let buckets = aggsFields["buckets"] as? [[String : Any]] else { return }
        entries = Mapper<VideoEntry>().mapArray(JSONArray: buckets)
    }
}

extension VideoContent {
    func barChartDataSet(_ colors: [UIColor]) -> DataSet? {
        guard let date = date else { return nil }
        let maxVal = entries.sorted(by: { $0.value > $1.value}).first?.value ?? 0.0
        
        let entriesList = entries.enumerated().compactMap { (index, videoEntry) -> DataEntry? in
            return videoEntry.barChartEntry(Float(maxVal), color: colors[index])
        }
        return DataSet(date, dataEntries: entriesList)
    }
}

class VideoEntry: Mappable, Equatable {
    
    var title: String       =   ""
    var value: CGFloat      =   0.0

    init(title: String, value: CGFloat) {
        self.title = title
        self.value = value
    }
    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title       <-  map["key"]
        value       <-  map["max_field.value"]
    }
    
    static func == (lhs: VideoEntry, rhs: VideoEntry) -> Bool {
        return lhs.title == rhs.title
    }

}

extension VideoEntry {
    func barChartEntry(_ max: Float, color: UIColor) -> DataEntry {
        let height: Float = max > 0 ? Float(value) / max : 0
        let font = UIFont.systemFont(ofSize: 15)
        let entry = DataEntry(color: color, height: height, textValue: String(format: "%0.2f", value), textValueFont: font, title: "\(title)", titleValueFont: font)
        return entry
    }
}
