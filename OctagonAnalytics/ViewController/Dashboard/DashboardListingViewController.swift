//
//  DashboardListingViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import MBProgressHUD
import AMPopTip

class DashboardListingViewController: BaseViewController {

    /// Dashboard loader object : used to load the dashboard items
    fileprivate var dashboardLoder = DashboardItemsLoader()
    
    /// Datesource: Array of Dashboard items
    fileprivate var dataSource: [DashboardItem]     =   []
    
    /// Tool tip to show the details of a dashboard
    fileprivate let popTip = PopTip()

    /// Refresh control
    var refreshControl: UIRefreshControl?
    
    /// Hud
    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()

    /// Dashboard Listing collection view
    @IBOutlet weak var dashboardListCollectionView: UICollectionView!
    
    /// Reload Button
    @IBOutlet weak var reloadButton: UIButton!

    private var searchText: String  =   ""
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialSetup()
        loadDashboardItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenUrlNotification(_:)), name: Notification.Name(AppDelegate.NotificationNames.redirectToUrl), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleOpenUrlNotification(_ notification: Notification) {
        redirectToDashboard()
    }

    override func leftBarButtons() -> [UIBarButtonItem] {
        return []
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        guard let layout = dashboardListCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let size = sizeForCell(dashboardListCollectionView)
        layout.itemSize = size
        layout.invalidateLayout()
    }
    
    //MARK: Private Functions
    private func initialSetup() {
        
        title = "Dashboards".localiz()
        reloadButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        reloadButton.titleLabel?.textAlignment = .center
        reloadButton.setTitle("NoDashboardMessage".localiz(), for: .normal)
        reloadButton.isHidden = true
        reloadButton.style(CurrentTheme.textStyleWith(reloadButton.titleLabel?.font.pointSize ?? 20, weight: .regular, color: CurrentTheme.standardColor))


        dashboardListCollectionView.delegate = self
        dashboardListCollectionView.dataSource = self
        dashboardListCollectionView.alwaysBounceVertical = true

        // Setup PopTip
        popTip.bubbleColor = CurrentTheme.darkBackgroundColor.withAlphaComponent(0.8)
        popTip.textColor = CurrentTheme.secondaryTitleColor
        popTip.font = UIFont.withSize(12.0, weight: .regular)
        
        refreshControl = UIRefreshControl()
        let refreshControlTitle = NSAttributedString(string: "Loading...".localiz(), attributes: [NSAttributedString.Key.foregroundColor : CurrentTheme.titleColor])
        refreshControl?.attributedTitle = refreshControlTitle
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl?.tintColor = CurrentTheme.standardColor
        
        guard let refresh = refreshControl else { return }

        dashboardListCollectionView.addSubview(refresh)
        
        if isIPhone {
            dashboardListCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        }

        dashboardListCollectionView.register(UINib(nibName: CellIdentifier.dashboardListHeaderView, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.dashboardListHeaderView)
    }
    
    @objc func refresh(_ control: UIRefreshControl) {
        loadDashboardItems(false)
    }
    
    private func loadDashboardItems(_ shouldShowHud: Bool = true) {
        
        // Load Data
        if shouldShowHud {
            hud.show(animated: true)
        }
        dashboardLoder.loadDashBoardItems { [weak self] (result, error) in

            self?.refreshControl?.endRefreshing()
            self?.hud.hide(animated: true)
            // Handle the response
            self?.filterDashboardItems()

            guard error == nil else {
                // Show the Error here
                self?.reloadButton.isHidden = false
                DLog(error?.localizedDescription)
                self?.dashboardListCollectionView.reloadSections(IndexSet(integer: 1))
                self?.showAlert(error?.localizedDescription)
                return
            }
            
            self?.reloadButton.isHidden = ((self?.dataSource.count ?? 0) > 0)
            
            self?.redirectToDashboard()
        }
    }
    
    /// Used in case of url schema (Eg.: Open app from Launch Pad)
    fileprivate func redirectToDashboard() {
        guard let dashboardIdToRedirect = Session.shared.dashboardIdToRedirect,
        let dashboardItem = dataSource.filter({ $0.id == dashboardIdToRedirect }).first else {
            return
        }
        showDashboard(dashboardItem)
        Session.shared.dashboardIdToRedirect = nil
    }
    
    fileprivate func showDashboard(_ dashboardItem: DashboardItem) {
        guard let dashboardVC = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: StoryboardIdentifier.dashboardViewController) as? DashboardViewController else { return }
        dashboardVC.dashboardItem = dashboardItem
        navigationController?.pushViewController(dashboardVC, animated: true)
        
    }
    
    func showDashboardWith(_ dashboardId: String) {
        guard let dashboardItem = dataSource.filter({ $0.id == dashboardId }).first else { return }
        showDashboard(dashboardItem)
    }
    
    //MARK: Button Action
    @IBAction func reloadButtonAction(_ sender: UIButton) {
        loadDashboardItems()
    }
}

extension DashboardListingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // First section contains only the search bar
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section != 0 else { return 0 }
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.dashboardListCellID, for: indexPath) as? DashboardListCollectionViewCell else {
            return DashboardListCollectionViewCell()
        }
        cell.showPopUpBlock = { [weak self] (rect, text) in

            guard let strongSelf = self else { return }
            
            let rectInCollectionView = collectionView.convert(rect, from: cell)
            let rectInView = self?.view.convert(rectInCollectionView, from: collectionView) ?? rectInCollectionView
            self?.popTip.show(text: text, direction: .left, maxWidth: 200, in: strongSelf.view, from: rectInView)
        }
        
        cell.dashboardItem = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DashboardListCollectionViewCell else { return }
        // Update UI here since the custom font size based on size class doesn't work unless cell is ready
        cell.updateUI()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        view.endEditing(true)
        
        let item = dataSource[indexPath.row]
        guard let selectedItem = item.copy() as? DashboardItem else { return }
        // Clearing data since copy object has issue (Content not cleared)
        resetPanelDataSource(selectedItem.panels)
        if selectedItem.fromTime.isEmpty || selectedItem.toTime.isEmpty {
            let cell = collectionView.cellForItem(at: indexPath)
            NavigationManager.shared.showDatePicker(collectionView, rect: cell?.frame ?? collectionView.frame, selectionBlock: { (sender, mode, fromDate, toDate, selectedDateString) in
                selectedItem.updateDateRange(fromDate, toDate: toDate)
                selectedItem.datePickerMode = mode
                selectedItem.selectedDateString = selectedDateString
                self.showDashboard(selectedItem)
            })
        } else {
            showDashboard(selectedItem)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard indexPath.section == 0 else { return UICollectionReusableView() }

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellIdentifier.dashboardListHeaderView, for: indexPath) as? DashboardListHeaderView else { return UICollectionReusableView() }
        header.searchClicked = { [weak self] (text, sender) in
            self?.popTip.hide()
            self?.searchText = text ?? ""
            self?.filterDashboardItems()
        }
        
        header.searchCancel = { [weak self] sender in
            self?.popTip.hide()
        }
        return header
    }
    
    private func filterDashboardItems() {
        guard !searchText.isEmpty else {
            dataSource = dashboardLoder.dashBoardItems
            dashboardListCollectionView.reloadSections(IndexSet(integer: 1))
            reloadButton.isHidden = dataSource.count > 0
            return
        }
        
        dataSource.removeAll()
        dataSource = dashboardLoder.dashBoardItems.filter { (item) -> Bool in
            item.title.lowercased().range(of: self.searchText.lowercased()) != nil
        }
        dashboardListCollectionView.reloadSections(IndexSet(integer: 1))
        reloadButton.isHidden = dataSource.count > 0
    }
    
    private func resetPanelDataSource(_ panels: [Panel]) {
        panels.forEach { (panel) in
            
            if panel is TilePanel {
                (panel as? TilePanel)?.tileList.removeAll()
            } else if panel is FaceTilePanel {
                (panel as? FaceTilePanel)?.faceTileList.removeAll()
            } else if panel is MetricPanel {
                (panel as? MetricPanel)?.metricsList.removeAll()
            } else if panel is SavedSearchPanel {
                (panel as? SavedSearchPanel)?.hits.removeAll()
            } else {
                panel.chartContentList.removeAll()
            }
        }
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        popTip.hide()
    }
}

extension DashboardListingViewController: UICollectionViewDelegateFlowLayout {
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            guard section == 0 else { return CGSize.zero }

            let height:CGFloat = isIPhone ? 50 : 60
            return CGSize(width: collectionView.frame.width, height: height)
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForCell(collectionView)
    }
    
    func sizeForCell(_ collectionView: UICollectionView) -> CGSize {
        let spacing = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
        let remainingWidth = (collectionView.frame.size.width - spacing)
        let width = isIPhone && !isLandscapeMode ? remainingWidth : remainingWidth / 2
        
        let height:CGFloat = isIPhone ? 60 : 100
        return CGSize(width: width, height: height)

    }
}

extension DashboardListingViewController {
    struct CellIdentifier {
        static let dashboardListCellID = "dashboardListCellID"
        static let dashboardListHeaderView = "DashboardListHeaderView"
    }
    
    struct StoryboardIdentifier {
        static let dashboardViewController = "DashboardViewController"
    }
}
