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
    
    private static let showLegendPriority: Float = 750
    private static let hideLegendPriority: Float = 650

    @IBOutlet weak var pieChartBaseView: UIView!
    @IBOutlet weak var legendBaseView: UIView!
    @IBOutlet var showLegendConstraint: NSLayoutConstraint!
    @IBOutlet var hideLegendConstraint: NSLayoutConstraint!
    private var piechartData: [PieChartNode] = []
    private var legendsView: ChartLegendsView!


    
    lazy var chartProvider: PiecharProvider = {
        piechartData = constructPieChartData()
        let isDonut = (panel?.visState as? PieChartVisState)?.isDonut ?? false
        let config = updatedConfiguration()
        let provider = SunburstProvider(configuration: config)
        provider.onSelect = nodeSelected
        provider.onDeselect = {
            self.deselectFieldAction?(self)
        }
        provider.onHighlight = nodeHighlighted
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
        addLegendView()
    }
    
    private func addPieChart() {
        pieChartBaseView.addSubview(chartVC.view)
        view.addConstraints(piechartViewConstraints)
        chartVC.view.translatesAutoresizingMaskIntoConstraints = false
        chartVC.view.backgroundColor = .clear
    }
    
    private func addLegendView() {
        legendsView = UINib.init(nibName: String(describing: ChartLegendsView.self), bundle: nil).instantiate(withOwner: self, options: nil).first as? ChartLegendsView
        legendBaseView.addSubview(legendsView)
        view.addConstraints(legendViewConstraints)
        legendsView.translatesAutoresizingMaskIntoConstraints = false
        legendsView.onSelect = legendSelected
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        piechartData = constructPieChartData()
        chartProvider.updateFromConfiguration(configuration: updatedConfiguration())
        updateLegends()
    }
    
    override func legendButtonAction(_ sender: UIButton) {
        legendEnableButton?.isSelected = !(legendEnableButton?.isSelected ?? false)
        
        switch legendEnableButton!.isSelected {
        case true:
            showLegends()
        case false:
            hideLegends()
        }
        view.layoutIfNeeded()
        chartProvider.updateFromConfiguration(configuration: updatedConfiguration())
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
    
    private func nodeHighlighted(node: PieChartNode) {
        guard let bucket = node.associatedObject as? Bucket,
            let aggregation = panel?.visState?.otherAggregationsArray[bucket.aggIndex] else { return }
        var dateComponant: DateComponents?
        if let selectedDates =  panel?.currentSelectedDates,
            let fromDate = selectedDates.0, let toDate = selectedDates.1 {
            dateComponant = fromDate.getDateComponents(toDate)
        }
        let filter = FilterProvider.shared.createFilter(bucket, dateComponents: dateComponant, agg: aggregation)
        showInfoFieldActionBlock?(self, [filter], nil)
    }
    
    func updatedConfiguration() -> PieChartConfiguration {
        
        let collapsedLayerThickness = PieChartConstant.collapsedArcThickness

        let config = PieChartConfiguration(nodes: piechartData,
        marginBetweenArcs: 1.0,
        expandedArcThickness: isDonut ? donutInnerLayerThickness : pieInnerLayerThickness,
        collapsedArcThickness: collapsedLayerThickness,
        maxExpandedArcCount: 1,
        innerRadius:isDonut ? donutRadius : 0, startingAngle: 0,
        strokeColor: SettingsBundleHelper.selectedTheme.darkBackgroundColor)
        
        return config
    }
   
   
}

extension PieChartViewController {
    func constructPieChartData() -> [PieChartNode] {
        guard let parsedAgg = panel?.parsedAgg else {
            return []
        }
        return parsedAgg.asPieChartData()
    }
}

extension PieChartViewController {
    var piechartViewConstraints: [NSLayoutConstraint] {
        return [ NSLayoutConstraint(item: chartVC.view!, attribute: .top, relatedBy: .equal, toItem: pieChartBaseView, attribute: .top, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: chartVC.view!, attribute: .left, relatedBy: .equal, toItem: pieChartBaseView, attribute: .left, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: chartVC.view!, attribute: .bottom, relatedBy: .equal, toItem: pieChartBaseView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: chartVC.view!, attribute: .width, relatedBy: .equal, toItem: pieChartBaseView, attribute: .width, multiplier: 1.0, constant: 0.0) ]
    }
    
    var legendViewConstraints: [NSLayoutConstraint] {
        return [ NSLayoutConstraint(item: legendsView!, attribute: .top, relatedBy: .equal, toItem: legendBaseView, attribute: .top, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: legendsView!, attribute: .left, relatedBy: .equal, toItem: legendBaseView, attribute: .left, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: legendsView!, attribute: .bottom, relatedBy: .equal, toItem: legendBaseView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                 NSLayoutConstraint(item: legendsView!, attribute: .right, relatedBy: .equal, toItem: legendBaseView, attribute: .right, multiplier: 1.0, constant: 0.0) ]
    }
}


extension PieChartViewController {
    //PieChart Calculations
    var availableHeight: CGFloat {
        return min(pieChartBaseView.frame.size.height, pieChartBaseView.frame.size.width)
    }
    
    var donutInnerLayerThickness: CGFloat {
        return ((legendEnableButton?.isSelected ?? false) && (UIDevice.current.userInterfaceIdiom == .phone)) ? PieChartConstant.expandedMinArcThickness : PieChartConstant.expandedMaxArcThickness
    }
    
    //Donut, Fixed Inner Layer Thickness
    var donutRadius: CGFloat {
        let height = (availableHeight - 10) / 2
        
        var layerCount = chartHeight(nodes: piechartData)
        if layerCount > 0 {
            layerCount -= 1 // Omit Inner layer as it has different thickness
        } else {
            return height // Default thickness
        }
        let donutRadius = height - donutInnerLayerThickness - ( CGFloat(layerCount) * PieChartConstant.collapsedArcThickness)
        return donutRadius
    }
    
    //PieChart, Dynamic Inner Layer Thickness
    var pieInnerLayerThickness: CGFloat {
        let height = (availableHeight - 10) / 2
        var layerCount = chartHeight(nodes: piechartData)
        if layerCount > 0 {
            layerCount -= 1 // Omit Inner layer as it has different thickness
        } else {
            return height // Default thickness
        }
        let thickness = height - ( CGFloat(layerCount) * PieChartConstant.collapsedArcThickness)
        return thickness
    }
    
    var isDonut: Bool {
        return (panel?.visState as? PieChartVisState)?.isDonut ?? false
    }
    
    private func chartHeight(nodes: [PieChartNode]) -> Int {
        
        var maxHeights: [Int] = []
        for node in nodes {
            maxHeights.append(findMaxHeight(node: node))
        }
        return maxHeights.max() ?? 0
    }
    
    private func findMaxHeight(node: PieChartNode) -> Int {
        var nodeHeight = 1 // include current Node
        
        var childrenHeight: [Int] = []
        for child in node.children {
            let childHeight = findMaxHeight(node: child)
            childrenHeight.append(childHeight)
        }
        let maxChildHeight = childrenHeight.max() ?? 0
        nodeHeight += maxChildHeight
        return nodeHeight
    }
}

extension PieChartViewController {
    //Legend View Operations
    private func updateLegends() {
       
        guard let legends = panel?.parsedAgg?.chartLegends else {
            return
        }
        
        var chartLegends = legends.map { legend in
            ChartLegend.init(text: legend.text, color: legend.color, shape: .rect(width: 18, height: 12))
        }
        
        chartLegends.sort { (lhs, rhs) -> Bool in
            lhs.text < rhs.text
        }
        
        legendsView?.setLegends(chartLegends)
    }
    
    private func showLegends() {
        showLegendConstraint.isActive = true
        hideLegendConstraint.isActive = false
    }
    
    private func hideLegends() {
        showLegendConstraint.isActive = false
        hideLegendConstraint.isActive = true
    }
    
    private func legendSelected(_ legend: ChartLegendType) {
        chartProvider.highlightNodes(legend.text)
    }
}
