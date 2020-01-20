//
//  PanelBaseViewController.swift
//  KibanaGo
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import MBProgressHUD
import MarqueeLabel

typealias FilterAppliedActionBlock = (_ sender: PanelBaseViewController,_ item: FilterProtocol) -> Void
typealias SelectFieldActionBlock = (_ sender: Any,_ item: FilterProtocol,_ widgetRect: CGRect?) -> Void
typealias DeselectFieldActionBlock = (_ sender: Any) -> Void
typealias MultiFilterAppliedActionBlock = (_ sender: PanelBaseViewController,_ item: [FilterProtocol]) -> Void
typealias ShowInfoFieldActionBlock = (_ sender: Any,_ item: [FilterProtocol],_ widgetRect: CGRect?) -> Void

enum PanelMode: Int {
    case normal         = 0
    case listing        = 1
}

class PanelBaseViewController: BaseViewController {
    
    @IBOutlet weak var shadowView: UIView?
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var displayContainerView: UIView!
    @IBOutlet weak var listTableView: UITableView?
    @IBOutlet weak var flipButton: UIButton?
    
    @IBOutlet weak var headerview: UIView?
    @IBOutlet weak var headerTitleLabel: MarqueeLabel?
    
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
        
        listTableView?.backgroundColor = CurrentTheme.cellBackgroundColor
        listTableView?.estimatedRowHeight = 40.0
        listTableView?.rowHeight = UITableView.automaticDimension
        listTableView?.dataSource = self
        listTableView?.delegate = self
        listTableView?.tableFooterView = UIView()
        listTableView?.register(UINib(nibName: NibName.bucketListTableViewCell, bundle: Bundle.main), forCellReuseIdentifier: CellIdentifiers.bucketListCellId)
        listTableView?.separatorColor = CurrentTheme.separatorColor
        listTableView?.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        listTableView?.register(UINib(nibName: NibName.listTableHeaderView, bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: CellIdentifiers.listTableHeaderView)

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
        listTableView?.reloadData()
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
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.animationType = .zoomIn
        hud.contentColor = CurrentTheme.darkBackgroundColor

        panel?.loadChartData({ [weak self] (result, error) in
            hud.hide(animated: true)
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
            listTableView?.isHidden = true
            displayContainerView?.isHidden = false
            flipButton?.setImage(UIImage(named: flipIconNormal), for: .normal)
        } else {
            listTableView?.isHidden = false
            displayContainerView?.isHidden = true
            listTableView?.reloadData()
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
}

extension PanelBaseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return panel?.buckets.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.bucketListCellId) as? BucketListTableViewCell
        cell?.bucketType = panel?.bucketType ?? .unKnown
        cell?.metricType = panel?.metricAggregation?.metricType ?? .unKnown
        cell?.backgroundColor = .clear
        cell?.chartItem = panel?.buckets[indexPath.row]
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = CurrentTheme.cellBackgroundColor

    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = CurrentTheme.headerViewBackground
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let fieldValue = panel?.buckets[indexPath.row], let fieldName = panel?.bucketAggregation?.field, let type = panel?.bucketType else { return }
        let metricType = panel?.metricAggregation?.metricType ?? .unKnown
        let selectedFilter = Filter(fieldName: fieldName, fieldValue: fieldValue, type: type, metricType: metricType)
        if !Session.shared.containsFilter(selectedFilter) {
            filterAction?(self, selectedFilter)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellIdentifiers.listTableHeaderView) as? ListTableHeaderView
        headerView?.setupHeader(panel?.bucketAggregation?.field, panel?.metricAggregation?.metricType.rawValue.capitalized)
        return headerView
    }
}

extension PanelBaseViewController {
    struct CellIdentifiers {
        static let bucketListCellId = "bucketListCellId"
        static let listTableHeaderView = "ListTableHeaderView"
    }
    
    struct NibName {
        static let bucketListTableViewCell = "BucketListTableViewCell"
        static let listTableHeaderView = "ListTableHeaderView"

    }
    
    var flipIconNormal: String {
        return CurrentTheme.isDarkTheme ? "FlipIconNormal-Dark" : "FlipIconNormal"
    }
    
    var flipIconSelected: String {
        return CurrentTheme.isDarkTheme ? "FlipIconSelected-Dark" : "FlipIconSelected"
    }
}
