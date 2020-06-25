//
//  VideoContent.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//
import ObjectMapper
import BarChartRace

class VideoContent {
    
    var configContent: VideoConfigContent?
    
    var date: Date?
    var entries: [VideoEntry]   =   []
    
    private var colors: [UIColor] = CurrentTheme.barChartRaceColors

    //MARK: Functions
    
    func updateContent(_ dict: [String: Any]) {
        guard let source = dict["_source"] as? [String: Any] else { return }

        if let timeFieldName = configContent?.timeField?.name,
            let dateString = source[timeFieldName] as? String {
            date = dateString.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        }

        var list: [[String: Any]] = []
        for field in configContent?.selectedFieldList ?? [] {
            let val = source[field.name] as? CGFloat ?? 0.0
            list.append(["title":field.name, "value": val])
        }

        entries = Mapper<VideoEntry>().mapArray(JSONArray: list)
    }
}

extension VideoContent {
    func barChartDataSet() -> DataSet? {
        guard let date = date else { return nil }
        let maxVal = entries.compactMap {$0.value}.reduce(0, +)
        
        var colorIndex = -1
        let entriesList = entries.enumerated().compactMap { [weak self] (index, videoEntry) -> DataEntry? in
            guard let strongSelf = self else { return nil}
            if (colorIndex + 1) >= strongSelf.colors.count {
                colorIndex = 0
            } else {
                colorIndex += 1
            }
            return videoEntry.barChartEntry(Float(maxVal), color: strongSelf.colors[colorIndex])
        }
        return DataSet(date, dataEntries: entriesList)
    }
}

class VideoEntry: Mappable {
    
    var title: String       =   ""
    var value: CGFloat      =   0.0

    init(title: String, value: CGFloat) {
        self.title = title
        self.value = value
    }
    //MARK: Functions
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title       <-  map["title"]
        value       <-  map["value"]
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
