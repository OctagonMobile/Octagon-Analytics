//
//  PieChartViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import Charts
import LanguageManager_iOS

class PieChartViewController: ChartBaseViewController {

    
    
    lazy var chartProvider: PiecharProvider = {
        let nodes = getPieChartData()
        let config = PieChartConfiguration(nodes: nodes, marginBetweenArcs: 1.0, expandedArcThickness: 40.0, innerRadius: 40.0, startingAngle: 0)
        let provider = SunburstProvider(configuration: config)
        return provider
    }()
    
    var chartVC: UIViewController {
        return chartProvider.pieChartVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        legendEnableButton?.isSelected = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func setupChart() {
        super.setupChart()
       
        let isDonut = (panel?.visState as? PieChartVisState)?.isDonut ?? false
        addPieChart()
    }
    
    private func addPieChart() {
        displayContainerView.addSubview(chartVC.view)
        
        let top = NSLayoutConstraint(item: chartVC.view!, attribute: .top, relatedBy: .equal, toItem: displayContainerView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: chartVC.view!, attribute: .left, relatedBy: .equal, toItem: displayContainerView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: chartVC.view!, attribute: .bottom, relatedBy: .equal, toItem: displayContainerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: chartVC.view!, attribute: .right, relatedBy: .equal, toItem: displayContainerView, attribute: .right, multiplier: 1.0, constant: 0.0)
        view.addConstraints([top, left, right, bottom])
        chartVC.view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func updatePanelContent() {
        super.updatePanelContent()
        chartProvider.updateChart(nodes: getPieChartData())
    }
}

extension PieChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        DLog("Chart Value Selected")
        
        guard let chartContent = entry.data as? ChartContent,
            let agg = panel?.bucketAggregation else { return }
      
        var dateComponant: DateComponents?
        if let selectedDates =  panel?.currentSelectedDates,
            let fromDate = selectedDates.0, let toDate = selectedDates.1 {
            dateComponant = fromDate.getDateComponents(toDate)
        }
        let filter = FilterProvider.shared.createFilter(chartContent, dateComponents: dateComponant, agg: agg)
        
        showInfoFieldActionBlock?(self, [filter], nil)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        DLog("Chart Selection cleared")
        chartView.highlightValues(nil)
        deselectFieldAction?(self)
    }
}


extension PieChartViewController {
    func getPieChartData() -> [PieChartNode] {
        
        guard let chartContentList = panel?.chartContentList else {
            return []
        }
        var colorIndex = 0
        let nodes: [PieChartNode] = chartContentList.compactMap {
            if colorIndex >= defaultColors.count { colorIndex = 0 }
            let color = defaultColors[colorIndex]
            colorIndex += 1
            return PieChartNode(name: $0.key, children: [], value: $0.displayValue, showName: false, image: nil, backgroundColor: color)
        }
        return nodes
    }
    
}


