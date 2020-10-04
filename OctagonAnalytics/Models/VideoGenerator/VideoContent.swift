//
//  VideoContent.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//
import OctagonAnalyticsService
import BarChartRace

class VideoContent {
    var date: Date?
    var entries: [VideoEntry]   =   []

    //MARK: Functions
    init(_ responseModel: VideoContentService) {
        self.date   =   responseModel.date
        self.entries    =   responseModel.entries.compactMap({ VideoEntry($0) })
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

class VideoEntry: Equatable {
    
    var title: String       =   ""
    var value: CGFloat      =   0.0

    init(title: String, value: CGFloat) {
        self.title = title
        self.value = value
    }
    //MARK: Functions
    init(_ responseModel: VideoEntryService) {
        self.title  =   responseModel.title
        self.value  =   responseModel.value
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
