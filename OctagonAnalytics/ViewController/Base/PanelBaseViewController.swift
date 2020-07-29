//
//  PanelBaseViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import MBProgressHUD
import MarqueeLabel
import OctagonAnalyticsService

typealias FilterAppliedActionBlock = (_ sender: PanelBaseViewController,_ item: FilterProtocol) -> Void
typealias SelectFieldActionBlock = (_ sender: Any,_ item: FilterProtocol,_ widgetRect: CGRect?) -> Void
typealias DeselectFieldActionBlock = (_ sender: Any) -> Void
typealias MultiFilterAppliedActionBlock = (_ sender: PanelBaseViewController,_ item: [FilterProtocol]) -> Void
typealias ShowInfoFieldActionBlock = (_ sender: Any,_ item: [FilterProtocol],_ widgetRect: CGRect?) -> Void


enum PanelMode: Int {
    case normal         = 0
    case listing        = 1
}

class PanelBaseViewController: BaseViewController, DataTableDelegate {
    
    @IBOutlet weak var shadowView: UIView?
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var displayContainerView: UIView!
    @IBOutlet weak var flipButton: UIButton?
    
    @IBOutlet weak var headerview: UIView?
    @IBOutlet weak var headerTitleLabel: MarqueeLabel?
    
    var dataTableAdapter: DataTableType!
    var dataTable: UIView!
    
    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()

    private var dataSource: [Bucket] = []
    private var listTableHeaders: [String] = []
    
    var panelMode: PanelMode = .normal
    
    var filterAction: FilterAppliedActionBlock?
    var multiFilterAction: MultiFilterAppliedActionBlock?
    
    var selectFieldAction: SelectFieldActionBlock?
    var deselectFieldAction: DeselectFieldActionBlock?
    
    
    var showInfoFieldActionBlock: ShowInfoFieldActionBlock?
    var shouldLoadData: Bool = true
    
    var panel: Panel? {
        didSet {
            setupPanel()
            loadChartData()
        }
    }
    
    var defaultColors: [UIColor] = []
    
    var eachGridWidth: CGFloat    =   0
    
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupHeader()
        
        if mainContainerView != nil {
            dataTableAdapter = SwiftDataTableAdapter(getDataTableConfig() , delegate: self)
            dataTable = dataTableAdapter.dataTable
            mainContainerView.addSubview(dataTable)
            setupTableConstraints()
            dataTable.isHidden = true
        }
       
        
        if isIPhone {
            NotificationCenter.default.addObserver(self, selector: #selector(PanelBaseViewController.deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shadowView?.style(.shadow(offset: CGSize(width: 0, height: 2), opacity: 0.3, colorAlpha: 0.5))
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.didDeviceRotationCompleted()
        }
        
    }
    
    internal func didDeviceRotationCompleted() {
        shadowView?.style(.shadow(offset: CGSize(width: 0, height: 2), opacity: 0.3, colorAlpha: 0.5))
    }
    
    
    //MARK: Setup
    func setupPanel() {
        // Override in subclass to setup Panel
        headerTitleLabel?.style(CurrentTheme.headLineTextStyle())
        headerTitleLabel?.backgroundColor = .clear
        headerTitleLabel?.text = panel?.visState?.title
        headerTitleLabel?.backgroundColor = .clear
        headerTitleLabel?.type = .leftRight
        headerTitleLabel?.tapToScroll = true
        headerTitleLabel?.speed = MarqueeLabel.SpeedLimit.duration(1.0)
    }
    
    func setupHeader() {
        
        flipButton?.setImage(UIImage(named: flipIconNormal), for: .normal)
        
        mainContainerView?.style(.roundCorner(5.0, 0.0, .clear))
        mainContainerView?.backgroundColor = CurrentTheme.cellBackgroundColor
        displayContainerView?.backgroundColor = CurrentTheme.cellBackgroundColor
    }
    
    @objc func deviceRotated() {}
    
    func updatePanelContent() {
        // Override in subclass
        if mainContainerView != nil {
            updateDataSource()
        }
        flipPanel(.normal)
    }
    
    //MARK: Load data from server
    func loadChartData() {
        // Override in subclass
        
        guard shouldLoadData else {
            updatePanelContent()
            return
        }
        
        MBProgressHUD.hide(for: view, animated: true)
        hud.show(animated: true)
        
        panel?.loadChartData({ [weak self] (result, error) in
            self?.hud.hide(animated: true)
            // Check for Errors
            self?.flipButton?.isHidden = (error != nil)
            
            guard error == nil else {
                // Show the Error here
                DLog(error?.localizedDescription)
                self?.updatePanelContent()
                
                if let errorDesc = error?.localizedDescription {
                    self?.showNoItemsAvailable(errorDesc)
                } else {
                    self?.panel?.visState?.type == .unKnown ? self?.showNoItemsAvailable("Unsupported Panel") : self?.showNoItemsAvailable()
                }
                return
            }
            
            self?.handleResponse(result)
        })
    }
    
    func handleResponse(_ result: Any?) {
        guard let items =  result as? [Any] else {
            updatePanelContent()
            return
        }
        
        if items.count <= 0 {
            panel?.visState?.type == .unKnown ? showNoItemsAvailable("Unsupported Panel") : showNoItemsAvailable()
        } else {
            // Handle the response
            hideNoItemsAvailable()
        }
        
        shouldLoadData = false
        updatePanelContent()
    }
    
    func flipPanel(_ mode: PanelMode) {
        
        // If current mode is same as previous mode don't flip
        guard panelMode != mode else { return }
        
        panelMode = (panelMode == .normal) ? .listing : .normal
        
        if panelMode == .normal {
            dataTable.isHidden = true
            displayContainerView?.isHidden = false
            flipButton?.setImage(UIImage(named: flipIconNormal), for: .normal)
        } else {
            dataTable.isHidden = false
            displayContainerView?.isHidden = true
            dataTableAdapter.reload()
            flipButton?.setImage(UIImage(named: flipIconSelected), for: .normal)
        }
        
        shadowView?.isHidden = true
        UIView.transition(with: mainContainerView, duration: 1, options: .transitionFlipFromLeft, animations: nil, completion: {[weak self] (completed) in
            self?.shadowView?.isHidden = false
        })
    }
    //MARK: List View Methods
    @IBAction func flipButtonAction(_ sender: UIButton) {
        
        let switchedMode: PanelMode =  (panelMode == .normal) ? .listing : .normal
        flipPanel(switchedMode)
    }
    
    func numberOfColumnsInDataTable(dataTable: DataTableType) -> Int {
        return listTableHeaders.count
    }
    
    func numberOfRowsInDataTable(dataTable: DataTableType) -> Int {
        return listTableHeaders.isEmpty ? 0 : dataSource.count
    }
    
    func didSelectItemInDataTable(dataTable: DataTableType, indexPath: IndexPath) {
        let data = dataTableAdapter.data(for: indexPath)
        
        if case DataTableValue.string( _, let bucket) = data,
            let bucketObj = bucket as? Bucket {
            
            var dateComponant: DateComponents?
            if let selectedDates =  panel?.currentSelectedDates,
                let fromDate = selectedDates.0, let toDate = selectedDates.1 {
                dateComponant = fromDate.getDateComponents(toDate)
            }
            
            let filters = bucketObj.getRelatedfilters(dateComponant)
            multiFilterAction?(self, filters)
        }
    }
    
    func dataForRowInDataTable(dataTable: DataTableType, atIndex index: Int) -> [DataTableValue] {
        return rowData(dataSource[index])
    }
    
    func headerTitleForColumnInDataTable(dataTable: DataTableType, atIndex index: Int) -> String {
        return listTableHeaders[index]
    }
}

extension PanelBaseViewController {
    struct CellIdentifiers {
        static let bucketListCellId = "bucketListCellId"
        static let listTableHeaderView = "ListTableHeaderView"
    }
    
    struct NibName {
        static let listTableHeaderView = "ListTableHeaderView"
        
    }
    
    var flipIconNormal: String {
        return CurrentTheme.isDarkTheme ? "FlipIconNormal-Dark" : "FlipIconNormal"
    }
    
    var flipIconSelected: String {
        return CurrentTheme.isDarkTheme ? "FlipIconSelected-Dark" : "FlipIconSelected"
    }
}

extension PanelBaseViewController {
    func getDataTableConfig() -> DataTableConfig {
        return DataTableConfig(headerTextColor: CurrentTheme.headLineTextStyle().color,
                               headerBackgroundColor: CurrentTheme.cellBackgroundColorPair.last?.withAlphaComponent(1.0) ?? CurrentTheme.cellBackgroundColor,
                               headerFont: CurrentTheme.headLineTextStyle().font,
                               selectedHeaderBackgroundColor: CurrentTheme.standardColor,
                               selectedHeaderTextColor: CurrentTheme.secondaryTitleColor,
                               rowTextColor: CurrentTheme.bodyTextStyle().color,
                               rowBackgroundColor: CurrentTheme.cellBackgroundColor,
                               rowFont: CurrentTheme.bodyTextStyle().font,
                               separatorColor: CurrentTheme.separatorColor,
                               sortArrowColor: CurrentTheme.secondaryTitleColor,
                               enableSorting: false)
    }
    
    private func setupTableConstraints() {
        if let header = headerview {
            NSLayoutConstraint.activate([
                dataTable.topAnchor.constraint(equalTo: header.layoutMarginsGuide.bottomAnchor),
                dataTable.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor, constant: 5),
                dataTable.bottomAnchor.constraint(equalTo: mainContainerView.layoutMarginsGuide.bottomAnchor),
                dataTable.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor, constant: -5),
            ])
        }
    }
}

extension PanelBaseViewController {
    
    func updateDataSource() {
        if let parentBuckets = panel?.chartContentList {
            var buckets = [Bucket]()
            for parent in parentBuckets {
                buckets.append(contentsOf: parent.items)
            }
            dataSource = buckets
        }
        updateTableHeaders()
        dataTableAdapter.reload()
    }
    
    //Subbucket to Table data conversion
    public func rowData(_ bucket: Bucket) -> [DataTableValue] {
        var currentBucket: Bucket? = bucket
        var rowData: [DataTableValue] = []
        while currentBucket != nil {
            var key = currentBucket?.key ?? ""
            if let rangeBucket = currentBucket as? RangeBucket {
                key = rangeBucket.stringValue
            } else if currentBucket?.bucketType == BucketType.dateHistogram {
                let milliSeconds = Int(currentBucket?.key ?? "") ?? 0
                let date = Date(milliseconds: milliSeconds)
                key = date.toFormat("YYYY-MM-dd")
            }
            
            if rowData.isEmpty {
                rowData.append(DataTableValue.string(key, bucket))
                if currentBucket!.displayValue.isInteger {
                    rowData.append(DataTableValue.int( Int(currentBucket!.displayValue), bucket))
                } else {
                    rowData.append(DataTableValue.double(currentBucket!.displayValue, bucket))
                }
            } else {
                rowData.insert(DataTableValue.string(key, bucket), at: 0)
            }
            currentBucket = currentBucket?.parentBkt
        }
        return rowData
    }
    
    
    private func updateTableHeaders() {
        guard let aggs = panel?.visState?.aggregationsArray else {
            listTableHeaders = []
            return
        }
        // Only works for one Metric and one or more sub buckets
        // Yet to figure out for more metrics
        var headerTitles:[String] = []
        var metricType: String = ""
        for agg in aggs {
            if agg.schema == "metric" {
//                headerTitles.insert(agg.field, at: 0)
                metricType = agg.metricType.rawValue.capitalized
            } else {
                headerTitles.append(agg.field)
            }
        }
        headerTitles.append(metricType)
        listTableHeaders = headerTitles
    }
}
