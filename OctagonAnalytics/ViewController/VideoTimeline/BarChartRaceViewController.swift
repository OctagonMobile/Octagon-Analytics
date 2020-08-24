//
//  BarChartRaceViewController.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/15/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import BarChartRace
import SwiftDate
import TGPControls
import ReplayKit

class BarChartRaceViewController: VideoTimelineBaseViewController {

    var barData: [VideoContent] = []
    
    //MARK: Outlets
    @IBOutlet weak var barChartView: BasicBarChart!
    
    private var colorsDict: [String: UIColor] = [:]
    private var currentColorIndex: Int = 0

    //MARK: Funnctions
    override func viewDidLoad() {
        super.viewDidLoad()
        title   =   "Bar Chart Video".localiz()
        recordIndicator.isHidden = shouldHideControls
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barChartView?.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordIndicator.layer.cornerRadius = recordIndicator.frame.width / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barChartView?.stop()
    }

    override func speedUpdated() {
        barChartView.timeInterval = TimeInterval(speed)
        if barChartView.playerState == .playing {
            barChartView.pause()
            barChartView.play()
        }
    }
    //MARK: Private Functions
    private func initialSetup() {
        //setup view
        setupView()
        
        //setup speed slider
        setupSliders()
        
        //setup bar chart race
        barChartView.delegate = self
        barChartView.backgroundColor = CurrentTheme.cellBackgroundColor
        barChartView.timeInterval = TimeInterval(speed)
        barChartView.titleColor = CurrentTheme.titleColor
        barChartView.valueColor = CurrentTheme.titleColor
        
        let uniqueVideoEntries = getUniqueVideoEntries()
        colors = CurrentTheme.barChartRaceColors(uniqueVideoEntries.count)
        let dataSetList = barData.compactMap { (videoContent) -> DataSet? in
            let colorSet: [UIColor] =  videoContent.entries.compactMap { (entry) -> UIColor? in
                if colorsDict[entry.title] == nil {
                    colorsDict[entry.title] = colors[currentColorIndex % colors.count]
                    currentColorIndex += 1
                }
                return colorsDict[entry.title] ?? CurrentTheme.standardColor
            }
            return videoContent.barChartDataSet(colorSet)
        }
        
        barChartView.setupBarChartRace(dataSetList, animated: true)
    }
    
   
    override func recordingStarted() {
        self.barChartView.play()
    }
    
    override func recordingStopped() {
        self.barChartView.stop()
        
    }
    
    override func pauseVideo() {
        barChartView.pause()
    }
    
    override func playVideo() {
        self.barChartView.play()
    }
    
    override func stopVideo() {
        self.barChartView.stop()
    }
    
    private func getUniqueVideoEntries() -> [VideoEntry] {
        var uniqueVideoEntries: [VideoEntry]    =   []
        barData.forEach { (videoContent) in
            videoContent.entries.forEach { (entry) in
                guard !uniqueVideoEntries.contains(entry) else { return }
                uniqueVideoEntries.append(entry)
            }
        }
        return uniqueVideoEntries
    }
    
    //MARK: Button Actions
    @IBAction func playButtonAction(_ sender: UIButton) {
        if barChartView.playerState == .playing {
            barChartView.pause()
        } else {
            barChartView.play()
        }
    }

}

extension BarChartRaceViewController: BarChartRaceDelegate {
    
    func playerStateUpdated(_ state: BasicBarChart.PlayerState) {
        var playButtonTitle = (state == .playing) ? "videoPause" : "videoPlay"
        playButtonTitle += CurrentTheme.isDarkTheme ? "-Dark" : "-Light"
        playButton.setImage(UIImage(named: playButtonTitle), for: .normal)
        
        if state == .stopped, recorder.isRecording {
            stopRecording()
        }
    }
    
    func currentDataSet(_ dataSet: DataSet, index: Int) {
        dateLabel.text = dataSet.date.toString(.custom("dd MMM yyyy"))
        guard videoConfig?.spanType == .seconds || videoConfig?.spanType == .minutes || videoConfig?.spanType == .hours else {
            timeLabel.text = ""
            return
        }
        timeLabel.text = dataSet.date.toString(.custom("HH:mm:ss"))
    }
}

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
