//
//  TagCloudViewController.swift
//  KibanaGo
//
//  Created by Rameez on 10/30/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

class TagCloudViewController: PanelBaseViewController {

    @IBOutlet weak var tagCloudView: DKTagCloudView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tagCloudView.titls = []
        let arraySlice = CurrentTheme.chartColors1.prefix(7)
        tagCloudView.randomColors = Array(arraySlice)
        tagCloudView.generate()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func setupPanel() {
        super.setupPanel()
        
        setupFont()
        tagCloudView?.backgroundColor = CurrentTheme.cellBackgroundColor
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()

        guard let panel = panel else { return }
        
        setupFont()
        tagCloudView.tagClickBlock =  { [weak self] (title: String?, index: Int) in
            DLog("Clicked \(String(describing: title))")
            // Show Details
            guard let strongSelf = self, let fieldName = panel.bucketAggregation?.field, index < panel.buckets.count else { return }
            
            let metricType = panel.metricAggregation?.metricType ?? .unKnown
            let interval = (panel.bucketType == BucketType.histogram) ?  panel.bucketAggregation?.params?.intervalInt : nil
            let selectedFilter = Filter(fieldName: fieldName, fieldValue: panel.buckets[index], type: panel.bucketType, metricType: metricType, interval: interval)
            if !Session.shared.containsFilter(selectedFilter) {
                strongSelf.selectFieldAction?(strongSelf, selectedFilter, nil)
            }
        }        
        
        let titles = panel.buckets.map({$0.key})
        tagCloudView.titls = titles
        tagCloudView.generate()
    }
    
    //MARK: Private
    fileprivate func setupFont() {
        guard let visState = panel?.visState as? TagCloudVisState else {
            return
        }
        
        if visState.maxFontSize > 0 {
            tagCloudView.maxFontSize = visState.maxFontSize
        }
        
        if visState.minFontSize > 0 {
            tagCloudView.minFontSize = visState.minFontSize
        }
        
        tagCloudView.font = tagCloudFont
    }
}

extension TagCloudViewController {
    var tagCloudFont: UIFont {
        let size =  CGFloat(Int(arc4random()) % tagCloudView.maxFontSize + tagCloudView.minFontSize)
        return UIFont.withSize(size, weight: .regular)
    }
}
