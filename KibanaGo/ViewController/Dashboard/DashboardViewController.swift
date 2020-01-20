//
//  DashboardViewController.swift
//  KibanaGo
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import AMPopTip
import LanguageManager_iOS

class DashboardViewController: BaseViewController {

    ///Screen is equally diveded horizontally in to 48.
    let numberOfColumns: UInt = 48
    
    ///CollectionView used to show the Panels.
    @IBOutlet weak var dashBoardCollectionView: UICollectionView!
    
    @IBOutlet weak var removeFiltersButton: UIButton!
    
    ///Dashboard Item Object.
    var dashboardItem = DashboardItem(JSON: [:])

    ///Array Of Panels.
    fileprivate var panels: [Panel] {
        return dashboardItem?.panels ?? []
    }
    
    ///Mosaic Layout of collectionview.
    fileprivate var mosaicLayout: MosaicLayout? {
        return (dashBoardCollectionView.collectionViewLayout as? MosaicLayout)
    }

    fileprivate var widgetsDictionary: [String: PanelBaseViewController] = [:]
    
    //Filter collectionview outlets
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    fileprivate let popTip = PopTip()

    fileprivate var hasFilters: Bool {
        return Session.shared.appliedFilters.count > 0
    }

    private let filtersHeight: CGFloat = 50
    private let filtersTopConstraintHeight: CGFloat = 16
//    private var showHeader: Bool = false

    @IBOutlet weak var topBarContainerView: UIView!
    @IBOutlet weak var filtersTitleLabel: UILabel!
    @IBOutlet weak var filtersHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filtersTopConstraint: NSLayoutConstraint!
    
    var savedSearchViewController: SavedSearchListViewController? {
        return widgetsDictionary.filter( {$0.value is SavedSearchListViewController }).values.first as? SavedSearchListViewController
    }
    
    private var timeRangeBarButton: UIBarButtonItem?
    private var timeRangeCustomButton: UIButton? {
        return timeRangeBarButton?.customView as? UIButton
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    var selectedFilterIndexPath: IndexPath?
    
    //MARK: Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        dashBoardCollectionView.register(UINib(nibName: "DashboardCollectionReusableView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")

        dashBoardCollectionView.alwaysBounceVertical = true
        dashBoardCollectionView.showsVerticalScrollIndicator = true
        dashBoardCollectionView.register(UINib(nibName: NibName.dashboardCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.dashboardCollectionViewCell)
        
        filterCollectionView.register(UINib(nibName: NibName.filterCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.filterCollectionViewCell)
        filtersTitleLabel.style(CurrentTheme.subHeadTextStyle())
        title = dashboardItem?.title ?? AppName
        mosaicLayout?.delegate = self
        
        popTip.bubbleColor = .clear
        popTip.shouldDismissOnTap = false

        setupWidgets()
        
        let theme = CurrentTheme
        removeFiltersButton.style(theme.bodyTextStyle(theme.separatorColorSecondary))
        removeFiltersButton.setTitleColor(theme.titleColor, for: .highlighted)
        let removeTitle = isIPhone ? "" : "Clear All".localiz()
        removeFiltersButton.setTitle(removeTitle, for: .normal)
        let image = CurrentTheme.isDarkTheme ? "RemoveFilter" : "ClearAll"
        removeFiltersButton.setImage(UIImage(named: image), for: .normal)
        
        //Configure Search bar
        configureSearchBar()
        setupFilterHeader()
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        var buttons = super.rightBarButtons()
        let reloadButton = UIBarButtonItem(image: UIImage(named: "reload"), style: .plain, target: self, action: #selector(reloadAction(_ :)))
        
        let dateString = (isIPhone && !isLandscapeMode) ? "" : dashboardItem?.displayDateString
        let selectedDateRange = dateString ?? ""
        
        let timeRangeCustomButton = UIButton(type: .custom)
        timeRangeCustomButton.titleLabel?.style(CurrentTheme.title3TextStyle(CurrentTheme.secondaryTitleColor))
        if isLandscapeMode {
            let spacing: CGFloat = 10
            if LanguageManager.shared.isRightToLeft {
                timeRangeCustomButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
                timeRangeCustomButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
            } else {
                timeRangeCustomButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
                timeRangeCustomButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
            }
        }
        timeRangeCustomButton.sizeToFit()
        timeRangeCustomButton.setTitle(selectedDateRange, for: .normal)
        timeRangeCustomButton.setImage(UIImage(named: "CalendarIcon"), for: .normal)
        timeRangeCustomButton.addTarget(self, action: #selector(dateSelectionButtonAction(_ :)), for: .touchUpInside)
        timeRangeBarButton = UIBarButtonItem(customView: timeRangeCustomButton)

        buttons.append(reloadButton)
        buttons.append(timeRangeBarButton!)
        return buttons
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var currentIndexPath: IndexPath?
        if let cell = dashBoardCollectionView.visibleCells.first {
            currentIndexPath = dashBoardCollectionView.indexPath(for: cell)
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            
            if let indexPath = currentIndexPath {
                self.dashBoardCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
            let spacing: CGFloat = isLandscapeMode ? 10 : 0
            self.timeRangeCustomButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
            self.timeRangeCustomButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)

            let dateString = (isIPhone && !isLandscapeMode) ? "" : self.dashboardItem?.selectedDateString
            self.timeRangeCustomButton?.setTitle(dateString, for: .normal)
            self.timeRangeCustomButton?.sizeToFit()
            self.dashBoardCollectionView.collectionViewLayout.invalidateLayout()
        }

    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        dashBoardCollectionView.collectionViewLayout.invalidateLayout()
    }
    

    @objc func reloadAction(_ sender: UIBarButtonItem) {
        refreshDashboard()
    }
    
    @IBAction func removeFiltersButtonAction(_ sender: Any) {
        showOkCancelAlert(AppName, "RemoveFilterAlert".localiz(), okTitle: YES, okActionBlock: { [weak self] in
            // Remove all filters & Reload
            Session.shared.appliedFilters.removeAll()
            self?.refreshDashboard()
        }, cancelTitle: NO)
    }
    
    @objc func dateSelectionButtonAction(_ sender: UIButton) {
        
        guard let dashboardItem = dashboardItem, let datePickerBarButton = timeRangeBarButton else { return }
        
        let fromDate = dashboardItem.fromTime.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        let toDate = dashboardItem.toTime.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")

        let quickPickerValue = QuickPicker(rawValue: dashboardItem.selectedDateString)
        NavigationManager.shared.showDatePicker(view, rect: view.frame, barButton: datePickerBarButton, mode: dashboardItem.datePickerMode, quickPickerValue: quickPickerValue, fromDate: fromDate, toDate: toDate) { (sender, mode, fromDate, toDate, selectedDateString) in
            self.dashboardItem?.updateDateRange(fromDate, toDate: toDate)
            self.dashboardItem?.datePickerMode = mode
            self.dashboardItem?.selectedDateString = selectedDateString
            let dateString = (isIPhone && !isLandscapeMode) ? "" : self.dashboardItem?.displayDateString
            self.timeRangeCustomButton?.setTitle(dateString, for: .normal)
            self.timeRangeCustomButton?.sizeToFit()
            self.refreshDashboard()
        }
    }
    
    func didSelectDate(_ fromDate: Date?, toDate: Date?, selectedDateString: String?) {
        
        self.dashboardItem?.updateDateRange(fromDate, toDate: toDate)
        let dateString = (isIPhone && !isLandscapeMode) ? "" : selectedDateString
        self.timeRangeCustomButton?.setTitle(dateString, for: .normal)
        timeRangeCustomButton?.sizeToFit()
        self.refreshDashboard()

    }

    override func leftBarButtonAction(_ sender: UIBarButtonItem) {
        Session.shared.appliedFilters.removeAll()
        super.leftBarButtonAction(sender)
    }
    
    fileprivate func updateTopBar() {
        filtersHeightConstraint.constant =  hasFilters ? filtersHeight : 0
        filtersTopConstraint.constant = hasFilters ? filtersTopConstraintHeight : 0
    }
    
    fileprivate func setupFilterHeader() {
        if isIPhone {
            let width:CGFloat = 50
            let rect = CGRect(x: 0, y: 0, width: -width, height: filtersHeight)
            let header = UIView(frame: rect)
            let label = UILabel(frame: header.bounds)
            header.backgroundColor = .clear
            label.style(CurrentTheme.subHeadTextStyle())
            label.text = "Filters:"
            header.addSubview(label)
            filterCollectionView.addSubview(header)
            filterCollectionView.contentInset = UIEdgeInsets(top: 0, left: width, bottom: 0, right: 0)
        }
    }
    
    fileprivate func setupWidgets() {
        for (index,panel) in panels.enumerated() {
            var panelViewController = PanelBaseViewController()
            let type = panel.visState?.type ?? .unKnown
            switch type {
            case .pieChart:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.pieChartViewController) as? PieChartViewController ?? PieChartViewController()
            case .histogram, .horizontalBar:
                
                if let xPosition = panel.visState?.xAxisPosition, (xPosition == .left || xPosition == .right) {
                    panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.horizontalBarChartViewController) as? HorizontalBarChartViewController ?? HorizontalBarChartViewController()
                } else {
                    panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.barChartViewController) as? BarChartViewController ?? BarChartViewController()
                }
                
            case .tagCloud, .t4pTagcloud:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.tagCloudViewController) as? TagCloudViewController ?? TagCloudViewController()
            case .table:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.contentListViewController) as? ContentListViewController ?? ContentListViewController()
            case .search:
                panelViewController = StoryboardManager.shared.storyBoard(.savedSearch).instantiateViewController(withIdentifier: ViewControllerIdentifiers.savedSearchListViewController) as? SavedSearchListViewController ?? SavedSearchListViewController()
                
                (panelViewController as? SavedSearchListViewController)?.didScrollToBoundary = { [weak self] (innerScrollView) in
                    
                    //Handle - if content size of the dashboard is less than panel size
                    if self?.dashBoardCollectionView.contentSize.height ?? 0 > self?.savedSearchViewController?.view.frame.size.height ?? 0 {
                        innerScrollView.isScrollEnabled = false
                    }
                }
            case .metric:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.metricsViewController) as? MetricsViewController ?? MetricsViewController()
            case .tile:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.tileViewController) as? TileViewController ?? TileViewController()
            case .heatMap:
                let mapType = (panel.visState as? MapVisState)?.mapType
                let storyboardId = (mapType == MapVisState.MapType.heatMap) ? ViewControllerIdentifiers.heatMapViewController :
                    ViewControllerIdentifiers.coordinateMapViewController
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: storyboardId) as? MapBaseViewController ?? PanelBaseViewController()
                (panelViewController as? HeatMapViewController)?.enableDashboardScrolling = { [weak self] ( enable ) in
                    self?.dashBoardCollectionView.isScrollEnabled = enable
                }
            case .mapTracking:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.mapTrackingViewController) as? MapTrackingViewController ?? PanelBaseViewController()
            case .vectorMap:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vectorMapViewController) as? VectorMapViewController ?? PanelBaseViewController()
            case .faceTile:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.faceTileViewController) as? FaceTileViewController ?? FaceTileViewController()
            case .neo4jGraph:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.graphViewController) as? GraphViewController ?? GraphViewController()

            case .html:
                panelViewController = StoryboardManager.shared.storyBoard(.search).instantiateViewController(withIdentifier: ViewControllerIdentifiers.webContentViewController) as? WebContentViewController ?? WebContentViewController()

            case .line, .area:
                panelViewController = StoryboardManager.shared.storyBoard(.charts).instantiateViewController(withIdentifier: ViewControllerIdentifiers.lineChartViewController) as? LineChartViewController ?? LineChartViewController()
                
            case .markdown:
                panelViewController = StoryboardManager.shared.storyBoard(.search).instantiateViewController(withIdentifier: ViewControllerIdentifiers.markDownViewController) as? MarkDownViewController ?? MarkDownViewController()

            default :
                DLog("Something wrong with Visualization Type: \(type.rawValue)")
                break
            }
            
            panelViewController.filterAction = { [weak self] (sender, itemSelected) in
                
                self?.applyFilters(itemSelected)
            }
            
            widgetsDictionary["\(index)"] = panelViewController
        }
    }
    
    //MARK: Private
    fileprivate func refreshDashboard() {
        
        NotificationCenter.default.post(name: Notification.Name(NotificationName.dashboardRefreshNotification), object: nil)
        updateTopBar()
        self.filterCollectionView.reloadData()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.filterCollectionView.reloadData()
        }
        
        widgetsDictionary.forEach( { $0.value.shouldLoadData = true } )
        dashBoardCollectionView.reloadData()
    }
    
    fileprivate func configureInfoView(_ selectedItem: FilterProtocol?, widgetRect: CGRect) {
        
        guard let infoView = Bundle.main.loadNibNamed("InfoView", owner: self, options: nil)?.first as? InfoView,
            let selectedFilter = selectedItem else {
            return
        }

        infoView.updateDetails(selectedFilter)

        infoView.drillDownAction = { [weak self] (sender, filterToBeApplied) in
            guard let filter = filterToBeApplied else { return }
            if !Session.shared.containsFilter(selectedFilter) {
                self?.applyFilters(filter)
            }
            self?.popTip.hide()
        }
        
        let originatingFrame = getCalculatedRectForInfoPopUp(infoView, widgetRect: widgetRect)
        
        popTip.show(customView: infoView, direction: .none, in: view, from: originatingFrame)
    }
    
    fileprivate func configureMultiFiltersInfoView(_ selectedItems: [FilterProtocol], widgetRect: CGRect) {
        
        guard let infoView = Bundle.main.loadNibNamed("FiltersInfoView", owner: self, options: nil)?.first as? FiltersInfoView else {
                return
        }
        
        infoView.updateDetails(selectedItems)

        infoView.drillDownAction = { [weak self] (sender, filtersToBeApplied) in
            guard let filters = filtersToBeApplied else { return }
            
            self?.applyFilters(filters)
            self?.popTip.hide()
        }
        
        let originatingFrame = getCalculatedRectForInfoPopUp(infoView, widgetRect: widgetRect)
        
        popTip.show(customView: infoView, direction: .none, in: view, from: originatingFrame)
    }
    
    private func getCalculatedRectForInfoPopUp(_ infoView: UIView, widgetRect: CGRect) -> CGRect {
        let rectInView = view.convert(widgetRect, from: dashBoardCollectionView)
        
        // Try Right side
        var infoViewFrame = infoView.frame
        infoViewFrame.origin.x = rectInView.origin.x + rectInView.width
        infoViewFrame.origin.y = rectInView.origin.y

        guard !view.frame.contains(infoViewFrame) else {
            return infoViewFrame
        }
        
        // Try Left side
        infoViewFrame = infoView.frame
        infoViewFrame.origin.x = rectInView.origin.x - infoViewFrame.width
        infoViewFrame.origin.y = rectInView.origin.y
        
        guard !view.frame.contains(infoViewFrame) else {
            return infoViewFrame
        }

        
        // Try Top side
        infoViewFrame = infoView.frame
        infoViewFrame.origin.x = rectInView.origin.x
        infoViewFrame.origin.y = rectInView.origin.y - infoViewFrame.height
        
        guard !view.frame.contains(infoViewFrame) else {
            return infoViewFrame
        }

        // Try Bottom side
        infoViewFrame = infoView.frame
        infoViewFrame.origin.x = rectInView.origin.x
        infoViewFrame.origin.y = rectInView.origin.y + rectInView.height

        guard !view.frame.contains(infoViewFrame) else {
            return infoViewFrame
        }

        // Random
        return infoViewFrame
    }
    
    private func configureSearchBar() {
        
        searchBar.style(.roundCorner(5.0, 1.0, CurrentTheme.cellBackgroundColor))
        searchBar.text = dashboardItem?.searchQuery
        searchBar.tintColor = CurrentTheme.enabledStateBackgroundColor
        searchBar.delegate = self
        searchBar.barTintColor = CurrentTheme.cellBackgroundColor
        searchBar.showsCancelButton = false
        searchBarHeightConstraint.constant   =   0
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.style(CurrentTheme.subHeadTextStyle())
        textFieldInsideSearchBar?.backgroundColor = CurrentTheme.cellBackgroundColor
    }
    
    private func applyFilters(_ itemsSelected: [FilterProtocol]) {
        
        let dateFilters = itemsSelected.filter({ $0 is DateHistogramFilter}) as? [DateHistogramFilter]
        let otherFilters = itemsSelected.filter({ !($0 is DateHistogramFilter) })

        var indexPathList: [IndexPath] = []
        for item in otherFilters {
            let success = Session.shared.addFilters(item)
            guard success else { continue }
                let indexPath = IndexPath(item: Session.shared.appliedFilters.count - 1, section: 0)
                indexPathList.append(indexPath)
        }

        filterCollectionView.insertItems(at: indexPathList)
        if Session.shared.appliedFilters.count > 1, let indexPath = indexPathList.last {
            filterCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
        
        guard let dateFilter = dateFilters?.first else {
            refreshDashboard()
            return
        }
        applyDateFilter(dateFilter)
    }
    
    private func applyDateFilter(_ dateFilter: DateHistogramFilter) {
        let fromDateString = dateFilter.calculatedFromDate?.toFormat("MMM dd yyyy HH:mm:ss") ?? ""
        let toDateString = dateFilter.calculatedToDate?.toFormat("MMM dd yyyy HH:mm:ss") ?? ""
        let selectedDateString = fromDateString + " - " + toDateString
        didSelectDate(dateFilter.calculatedFromDate, toDate: dateFilter.calculatedToDate, selectedDateString: selectedDateString)
    }

    
    private func applyFilters(_ itemSelected: FilterProtocol) {
        
        // Reload all the panels in dashboard
        if let dateFilter = itemSelected as? DateFilter {
            let fromDateString = dateFilter.calculatedFromDate?.toFormat("MMM dd yyyy HH:mm:ss") ?? ""
            let toDateString = dateFilter.calculatedToDate?.toFormat("MMM dd yyyy HH:mm:ss") ?? ""
            let selectedDateString = fromDateString + " - " + toDateString
            didSelectDate(dateFilter.calculatedFromDate, toDate: dateFilter.calculatedToDate, selectedDateString: selectedDateString)
        } else {
            // Reset Should reload the collectionview
            Session.shared.addFilters(itemSelected)
            let indexPath = IndexPath(item: Session.shared.appliedFilters.count - 1, section: 0)
            filterCollectionView.insertItems(at: [indexPath])
            if Session.shared.appliedFilters.count > 1 {
                filterCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
            refreshDashboard()
        }
    }
    
    private func applyImageFilter(_ itemSelected: FilterProtocol) {
        
        // Only one Image filter can be applied at a time
        if Session.shared.containsFilter(itemSelected) {
            guard let indexOfImageFilter = Session.shared.appliedFilters.index(where: { ($0 as? ImageFilter)?.id == ImageFilter.Constant.imageFilterId}) else { return }
            Session.shared.appliedFilters[indexOfImageFilter] = itemSelected
        } else {
            Session.shared.addFilters(itemSelected)
            let indexPath = IndexPath(item: Session.shared.appliedFilters.count - 1, section: 0)
            filterCollectionView.insertItems(at: [indexPath])
            if Session.shared.appliedFilters.count > 1 {
                filterCollectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
        refreshDashboard()
    }
}

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if collectionView == filterCollectionView {
            return Session.shared.appliedFilters.count
        }
        return panels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == filterCollectionView {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.filterCollectionViewCell, for: indexPath) as? FilterCollectionViewCell else { return UICollectionViewCell() }

            cell.filter = Session.shared.appliedFilters[indexPath.row]
            cell.isFilterSelected = (indexPath == selectedFilterIndexPath)
            cell.removeFilterActionBlock = { [weak self] (sender, filterToBeRemoved) in
                guard let filterToBeRemoved = filterToBeRemoved else { return }
                guard let index = Session.shared.appliedFilters.index(where: {$0.isEqual(filterToBeRemoved)}) else {
                    return
                }
                Session.shared.removeFilter(filterToBeRemoved)
                self?.selectedFilterIndexPath = nil

                self?.filterCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                self?.refreshDashboard()
            }
            
            cell.invertFilterActionBlock = { [weak self] (sender, filterToBeInverted) in
                guard let filterToBeInverted = filterToBeInverted else { return }
                guard let index = Session.shared.appliedFilters.index(where: {$0.isEqual(filterToBeInverted)}) else { return }

                Session.shared.appliedFilters[index] = filterToBeInverted
                self?.refreshDashboard()
            }
            
            return cell
        }
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.dashboardCollectionViewCell, for: indexPath) as? DashboardCollectionViewCell else { return UICollectionViewCell() }
        let panel = panels[indexPath.row]
        let key = "\(indexPath.row)"
        let widgetViewController: PanelBaseViewController = widgetsDictionary[key] ?? PanelBaseViewController()
        widgetViewController.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(widgetViewController.view)

        if widgetViewController.parent != self {
            addChild(widgetViewController)
        }

        if let mosaicLayout = (dashBoardCollectionView.collectionViewLayout as? MosaicLayout) {
            widgetViewController.eachGridWidth = floor(dashBoardCollectionView.frame.width / CGFloat(mosaicLayout.columnsQuantity))
        }

        // update dashboard item
        panel.dashboardItem = dashboardItem

        widgetViewController.panel = panel

        cell.viewController = widgetViewController
        cell.selectFieldAction = { [weak self] (sender, selectedItem, widgetRect) in
            
            if selectedItem is Filter  || selectedItem is DateFilter {
                guard let rect = widgetRect else { return }
                self?.configureInfoView(selectedItem, widgetRect: rect)
            } else if selectedItem is ImageFilter {
                self?.applyImageFilter(selectedItem)
            } else if selectedItem is LocationFilter {
                self?.applyFilters(selectedItem)
            }

        }
        
        cell.showInfoFieldActionBlock = { [weak self] (sender, selectedItems, widgetRect) in
            guard let rect = widgetRect else { return }
            self?.configureMultiFiltersInfoView(selectedItems, widgetRect: rect)
        }
        
        cell.deselectFieldAction = { [weak self] (sender) in
            self?.popTip.hide()
        }
        
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard  collectionView == filterCollectionView else { return }
        // Filter collection view tapped
        
        let selectedFilter = Session.shared.appliedFilters[indexPath.row]
        guard !selectedFilter.isInverted else { return }

        selectedFilterIndexPath = indexPath == selectedFilterIndexPath ? nil : indexPath
        filterCollectionView.reloadData()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        savedSearchViewController?.enableTableViewScrolling()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        popTip.hide()
        
        view.layoutIfNeeded()
        
        let searchBarHeightToHide: CGFloat = 50
        searchBarHeightConstraint.constant = scrollView.contentOffset.y > searchBarHeightToHide ? 0 : 56
        
        let filtersBarHeightToHide: CGFloat = 100
        let shouldShowFilter = hasFilters && scrollView.contentOffset.y < filtersBarHeightToHide
        filtersHeightConstraint.constant = shouldShowFilter ? filtersHeight : 0
        filtersTopConstraint.constant = shouldShowFilter ? filtersTopConstraintHeight : 0

        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var font = UIFont.systemFont(ofSize: 15)
        if let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
            font = cell.titleLabel.font
        }
        var calculatedWidth = Session.shared.appliedFilters[indexPath.row].calculatedWidth(withConstraintedHeight: collectionView.frame.size.height, font)
        calculatedWidth = calculatedWidth + 20 // 15 - Spacing
        return CGSize(width: calculatedWidth, height: collectionView.frame.size.height)
    }
}


extension DashboardViewController: MosaicLayoutDelegate {

    func numberOfColumns(in collectionView: UICollectionView!) -> UInt {
        return isIPhone && !isLandscapeMode ? 1 : numberOfColumns
    }
    

    func collectionView(_ collectionView: UICollectionView!, relativeHeightForItemAt indexPath: IndexPath!) -> Float {
        if isIPhone && !isLandscapeMode {
            let panel = panels[indexPath.row]
            if panel.visState?.type == PanelType.tile, let colWidth = mosaicLayout?.columnWidth() {
                let height = Float(collectionView.frame.size.height) / colWidth
                return height < 1 ? Float(1) : height
            }
            return Float(1)
        }
        
        let panel = panels[indexPath.row]
        return Float(panel.height)
    }
    
    func collectionView(_ collectionView: UICollectionView!, widthForItemAt indexPath: IndexPath!) -> Float {
        if isIPhone && !isLandscapeMode {
            return Float(1)
        }

        let panel = panels[indexPath.row]
        return Float(panel.width)
    }
}

extension DashboardViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dashboardItem?.searchQuery = searchBar.text ?? ""
        refreshDashboard()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        popTip.hide()
    }
}

extension DashboardViewController {
    struct CellIdentifiers {
        static let dashboardCollectionViewCell = "DashboardCollectionViewCell"
        static let filterCollectionViewCell = "FilterCollectionViewCell"
    }
    
    struct NibName {
        static let dashboardCollectionViewCell = "DashboardCollectionViewCell"
        static let filterCollectionViewCell = "FilterCollectionViewCell"
    }
    
    struct ViewControllerIdentifiers {
        static let pieChartViewController           = "PieChartViewController"
        static let barChartViewController           = "BarChartViewController"
        static let horizontalBarChartViewController = "HorizontalBarChartViewController"
        static let tagCloudViewController           = "TagCloudViewController"
        static let metricsViewController            = "MetricsViewController"
        static let contentListViewController        = "ContentListViewController"
        static let savedSearchListViewController    = "SavedSearchListViewController"
        static let tileViewController               = "TileViewController"
        static let heatMapViewController            = "HeatMapViewController"
        static let coordinateMapViewController      = "CoordinateMapViewController"
        static let mapTrackingViewController        = "MapTrackingViewController"
        static let vectorMapViewController          = "VectorMapViewController"
        static let faceTileViewController           = "FaceTileViewController"
        static let graphViewController              = "GraphViewController"
        static let webContentViewController         = "WebContentViewController"
        static let lineChartViewController          = "LineChartViewController"
        static let markDownViewController           = "MarkDownViewController"
    }
}

