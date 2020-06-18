//
//  BarChartRaceViewController.swift
//  OctagonAnalytics
//
//  Created by Kishore Kumar on 6/15/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import BarChartRace

class BarChartRaceViewController: UIViewController {
    
    var barData: [VideoContent] = []
    @IBOutlet weak var dateLabel: UILabel!

    //MARK: Outlets
    @IBOutlet weak var barChartView: BasicBarChart!
    
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var colors: [UIColor] = CurrentTheme.barChartRaceColors
    
    //MARK: Funnctions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateChart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    private func updateChart()  {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self,
                strongSelf.currentIndex <= strongSelf.barData.count - 1 else {
                    timer.invalidate()
                    return
            }
            let videoEntry = strongSelf.barData[strongSelf.currentIndex]
            let dataEntries = videoEntry.entries.enumerated().compactMap { (index, videoEntry) -> DataEntry? in
                let colorIndex = index < strongSelf.colors.count - 1 ? index : 0
                return videoEntry.barChartEntry(strongSelf.colors[colorIndex])
            }
            strongSelf.barChartView.updateDataEntries(dataEntries: dataEntries, animated: true)
            
            strongSelf.currentIndex += 1
            if let date = videoEntry.date {
                strongSelf.dateLabel.text = "\(date.toString())"
            }
        }
        timer?.fire()
    }
}
