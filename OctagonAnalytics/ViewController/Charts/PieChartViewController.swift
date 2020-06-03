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
        let isDonut = (panel?.visState as? PieChartVisState)?.isDonut ?? false
        let config = PieChartConfiguration(nodes: nodes,
                                           marginBetweenArcs: 1.0,
                                           expandedArcThickness: 80.0,
                                           collapsedArcThickness: 30.0,
                                           maxExpandedArcCount: 1,
                                           innerRadius: isDonut ? 40.0 : 0, startingAngle: 0,
                                           strokeColor: SettingsBundleHelper.selectedTheme.darkBackgroundColor)
        
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
        addPieChart()
    }
    
    private func addPieChart() {
        displayContainerView.addSubview(chartVC.view)
        
        let top = NSLayoutConstraint(item: chartVC.view!, attribute: .top, relatedBy: .equal, toItem: displayContainerView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let left = NSLayoutConstraint(item: chartVC.view!, attribute: .left, relatedBy: .equal, toItem: displayContainerView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: chartVC.view!, attribute: .bottom, relatedBy: .equal, toItem: displayContainerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let width = NSLayoutConstraint(item: chartVC.view!, attribute: .width, relatedBy: .equal, toItem: displayContainerView, attribute: .height, multiplier: 1.0, constant: 0.0)
        view.addConstraints([top, left, width, bottom])
        chartVC.view.translatesAutoresizingMaskIntoConstraints = false
        chartProvider.onSelect = nodeSelected
        chartProvider.onDeselect = {
            self.deselectFieldAction?(self)
        }
    }
    
    private func nodeSelected(node: PieChartNode) {
        guard let bucket = node.associatedObject as? Bucket else { return }
        
          var dateComponant: DateComponents?
          if let selectedDates =  panel?.currentSelectedDates,
              let fromDate = selectedDates.0, let toDate = selectedDates.1 {
              dateComponant = fromDate.getDateComponents(toDate)
          }
          let filters = bucket.getRelatedfilters(dateComponant)
          
          showInfoFieldActionBlock?(self, filters, nil)
    }

    override func updatePanelContent() {
        super.updatePanelContent()
        chartProvider.updateChart(nodes: getPieChartData())
    }
}

extension PieChartViewController {
    func getPieChartData() -> [PieChartNode] {
        guard let parsedAgg = panel?.parsedAgg else {
            return []
        }
        return parsedAgg.asPieChartData()
    }
}


