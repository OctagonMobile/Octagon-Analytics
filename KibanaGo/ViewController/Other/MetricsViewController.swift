//
//  MetricsViewController.swift
//  KibanaGo
//
//  Created by Rameez on 11/6/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit

class MetricsViewController: PanelBaseViewController {

    @IBOutlet weak var metricsCollectionView: UICollectionView!
    
    var metricList: [Metric] {
     return (panel as? MetricPanel)?.metricsList ?? []
    }
    
    fileprivate var fontSize: CGFloat {
        return (panel?.visState as? MetricVisState)?.fontSize ?? 20.0
    }
    
    fileprivate var metricWidth: CGFloat {
        return eachGridWidth * 2
    }
    
    fileprivate var calculatedHeight: CGFloat   =   0.0
    fileprivate var cellWidthArray: [CGFloat]   =   []
    
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        metricsCollectionView.register(UINib(nibName: NibName.metricCellNib, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.metricsCellId)
        metricsCollectionView.delegate = self
        metricsCollectionView.dataSource = self
        
        metricsCollectionView.backgroundColor = CurrentTheme.cellBackgroundColor
        (metricsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 0.0
        (metricsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 0.0

    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        computeCellSize()
        metricsCollectionView.reloadData()
    }
        
    //Private Functions
    
    fileprivate func numberOfColumns() -> Int {
        
        view.layoutIfNeeded()
        let columns = Int(round(metricsCollectionView.frame.width / metricWidth))
        return columns > 0 ? columns : 1
    }
    
    fileprivate func calculatedHeight(_ targetSize: CGSize) -> CGFloat {
        var largestHieght: CGFloat = 0.0
        
        guard let cell = Bundle.main.loadNibNamed(NibName.metricCellNib, owner: self, options: nil)?.first as? MetricsCollectionViewCell  else {
            return largestHieght
        }
        cell.fontSize = fontSize

        let metric = metricList.max { (first, second) -> Bool in
            cell.metric = first
            let firstMetricHeight = cell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.defaultHigh, verticalFittingPriority: UILayoutPriority.fittingSizeLevel).height
            
            cell.metric = second
            let secondMetricHeight = cell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.defaultHigh, verticalFittingPriority: UILayoutPriority.fittingSizeLevel).height

            return firstMetricHeight < secondMetricHeight

        }
        
        cell.metric = metric
        largestHieght = cell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.defaultHigh, verticalFittingPriority: UILayoutPriority.fittingSizeLevel).height

        return largestHieght
    }
    
    //MARK:
    fileprivate func computeCellSize() {
        
        var heightsArray: [CGFloat] = []
        cellWidthArray = []

        let columns = numberOfColumns()
        let remainingItems = metricList.count % columns
        var numberOfRows = 0
        for (index, _) in metricList.enumerated() {
            
            if (index + 1) % columns == 0 {
                numberOfRows += 1
            }
            
            let devider = index < remainingItems ? remainingItems : numberOfColumns()
            let width = floor(metricsCollectionView.frame.width / CGFloat(devider))
            cellWidthArray.append(width)
            
            let height = calculatedHeight(CGSize(width: width, height: 0.0))
            heightsArray.append(height)
        }
        
        if remainingItems > 0 {
            numberOfRows += 1
        }
        
        calculatedHeight = heightsArray.max(by: { $0 >= $1 }) ?? 0.0
        
        let totalRowHeights = CGFloat(numberOfRows) * calculatedHeight
        if totalRowHeights < metricsCollectionView.frame.height {
            calculatedHeight = metricsCollectionView.frame.height / CGFloat(numberOfRows)
        }
    }
    

}

extension MetricsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.metricsCellId, for: indexPath) as? MetricsCollectionViewCell
        cell?.metric = metricList[indexPath.row]
        cell?.fontSize = fontSize

        return cell ?? MetricsCollectionViewCell()
    }
}

extension MetricsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = cellWidthArray.count <= indexPath.row ? 0.0 : cellWidthArray[indexPath.row]
        return CGSize(width: width, height: calculatedHeight)
    }
}

extension MetricsViewController {
    struct CellIdentifiers {
        static let metricsCellId = "MetricsCollectionViewCellId"
    }
    
    struct NibName {
        static let metricCellNib = "MetricsCollectionViewCell"
    }

}
