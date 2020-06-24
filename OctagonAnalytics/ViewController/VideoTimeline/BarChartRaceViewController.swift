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

class BarChartRaceViewController: UIViewController {
    
    var speed: Float    =   0.5
    var barData: [VideoContent] = []
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var controlsHolder: UIView!
    
    //MARK: Outlets
    @IBOutlet weak var barChartView: BasicBarChart!
    
    private var currentIndex: Int = 0
    private var timer: Timer?

    //MARK: Funnctions
    override func viewDidLoad() {
        super.viewDidLoad()
        title   =   "Bar Chart Video".localiz()
        view.backgroundColor = CurrentTheme.cellBackgroundColor
        controlsHolder.backgroundColor = CurrentTheme.lightBackgroundColor
        playButton.backgroundColor = CurrentTheme.standardColor
        
        dateLabel.style(CurrentTheme.textStyleWith(dateLabel.font.pointSize, weight: .semibold))

        barChartView.delegate = self
        barChartView.backgroundColor = CurrentTheme.cellBackgroundColor
        barChartView.timeInterval = TimeInterval(speed)
        
        let dataSetList = barData.compactMap { (videoContent) -> DataSet? in
            return videoContent.barChartDataSet()
        }
        barChartView.setupBarChartRace(dataSetList, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barChartView?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        barChartView?.stop()
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
        let playButtonTitle = (state == .playing) ? "TrackingPauseIcon" : "TrackingPlayIcon"
        playButton.setImage(UIImage(named: playButtonTitle), for: .normal)
    }
    
    func currentDataSet(_ dataSet: DataSet) {
        dateLabel.text = dataSet.date.toString(.custom("dd MMM yyyy"))
    }
}
