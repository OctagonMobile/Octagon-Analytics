//
//  SavedSearchListViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/13/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import MBProgressHUD
import EverLayout

class SavedSearchListViewController: PanelBaseViewController {

    /// Saved Search Panel object
    fileprivate var savedSearchPanel: SavedSearchPanel {
        return (panel as? SavedSearchPanel)!
    }

    /// This CollectionView is used to provide horizontal scrolling
    @IBOutlet weak var searchListCollectionView: UICollectionView!
    
    /// Next Button
    @IBOutlet weak var nextButton: UIButton!
    
    /// Previous Button
    @IBOutlet weak var previousButton: UIButton!
    
    /// Page number label
    @IBOutlet weak var pageNumberLabel: UILabel!

    /// Spacing Between each columns
    fileprivate var spacingBetweenColumn        = 5
    
    /// Each column's width
    fileprivate var eachColumnWidth: CGFloat    = 200.0
    
    /// Datasource for the collectionview
    fileprivate var dataSource: [SavedSearch] {
        return (panel as? SavedSearchPanel)?.hits ?? []
    }
    
    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()

    /// Datasource for the collectionview
    var didScrollToBoundary: DidScrollToBoundary?
    
    /// Page number : Starts from 0
    fileprivate var pageNumber: Int             = 0
    
    /// Total number of pages
    fileprivate var totalNumberOfPages: Int {
        return Int(ceil(Double(savedSearchPanel.totalSavedSearchCount) / Double(SavedSearchPanel.Constant.pageSize)))
    }
    
    @IBOutlet weak var customTemplateCollectionView: UICollectionView?
    
    fileprivate var customTemplateDataProvider = CustomTemplateDataProvider()
    
    fileprivate let columnLayout = CustomTemplateLayout()

    //MARK: Overridden Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchListCollectionView.backgroundColor = CurrentTheme.cellBackgroundColor
        searchListCollectionView.register(UINib(nibName: NibName.savedSearchCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifiers.savedSearchCollectionViewCell)

        searchListCollectionView.delegate = self
        searchListCollectionView.dataSource = self
        
        previousButton.isEnabled = false
        
        pageNumberLabel.style(CurrentTheme.headLineTextStyle())
        
        let pagingLeftArrowIcon = CurrentTheme.isDarkTheme ? "PagingLeftArrow-Dark" : "PagingLeftArrow"
        let pagingLeftArrowHighlightIcon = CurrentTheme.isDarkTheme ? "PagingLeftArrowHighlighted-Dark" : "PagingLeftArrowHighlighted"
        let pagingLeftArrowDisabledIcon = CurrentTheme.isDarkTheme ? "PagingLeftArrowHighlighted" : "PagingLeftArrowDisabled"

        let pagingRightArrowIcon = CurrentTheme.isDarkTheme ? "PagingRightArrow-Dark" : "PagingRightArrow"
        let pagingRightArrowHighlightIcon = CurrentTheme.isDarkTheme ? "PagingRightArrowHighlighted-Dark" : "PagingRightArrowHighlighted"
        let pagingRightArrowDisabledIcon = CurrentTheme.isDarkTheme ? "PagingRightArrowHighlighted" : "PagingRightArrowDisabled"

        previousButton.setImage(UIImage(named: pagingLeftArrowIcon), for: .normal)
        previousButton.setImage(UIImage(named: pagingLeftArrowHighlightIcon), for: .highlighted)
        previousButton.setImage(UIImage(named: pagingLeftArrowDisabledIcon), for: .disabled)

        nextButton.setImage(UIImage(named: pagingRightArrowIcon), for: .normal)
        nextButton.setImage(UIImage(named: pagingRightArrowHighlightIcon), for: .highlighted)
        nextButton.setImage(UIImage(named: pagingRightArrowDisabledIcon), for: .disabled)

//        customTemplateCollectionView?.dataSource = customTemplateDataProvider
//        customTemplateCollectionView?.delegate = customTemplateDataProvider
        customTemplateCollectionView?.isHidden = true
        searchListCollectionView?.isHidden = false
        flipButton?.isHidden = true
        
        customTemplateCollectionView?.register(CustomCardCell.self, forCellWithReuseIdentifier: CellIdentifiers.CustomCardCell)

        customTemplateCollectionView?.collectionViewLayout = columnLayout
        customTemplateCollectionView?.alwaysBounceVertical = true
        
//        updateUIFormat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(dashboardRefresh(_ :)), name: Notification.Name(NotificationName.dashboardRefreshNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(NotificationName.dashboardRefreshNotification), object: nil)
    }

    override func loadChartData() {
        loadSavedSearch()
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        
        updateUI()
        searchListCollectionView.reloadData()
    }
    
    override func deviceRotated() {
        customTemplateCollectionView?.reloadData()
    }
    
    @objc func dashboardRefresh(_ notification: Notification)  {
        // handle dashboard refresh action
        resetPanel()
    }

    private func resetPanel() {
        savedSearchPanel.hits.removeAll()
        searchListCollectionView.reloadData()
        
        pageNumber = 0
        updateUI()
    }
    //MARK: Public Functions
    
    func enableTableViewScrolling() {
        guard let searchListCollectionView = searchListCollectionView,
            searchListCollectionView.numberOfItems(inSection: 0) > 0 ,
            let cell = searchListCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? SavedSearchCollectionViewCell  else { return }
        
        cell.searchListTableView.isScrollEnabled = true
    }
    
    override func flipPanel(_ mode: PanelMode) {
        super.flipPanel(mode)
//        updateUIFormat()
    }
    
    internal func updateUIFormat() {
        let isNormal = (panelMode == .normal)
        searchListCollectionView.isHidden = isNormal
        customTemplateCollectionView?.isHidden = !isNormal
    }

    //MARK: Button Actions
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        
        // If Data is loading then block the action
        guard pageNumber < (totalNumberOfPages - 1) , !shouldLoadData  else { return }
        shouldLoadData = true
        pageNumber += 1
        loadSavedSearch(true)
    }
    
    @IBAction func previousButton(_ sender: UIButton) {
        
        // If Data is loading then block the action
        guard pageNumber > 0, !shouldLoadData  else { return }
        shouldLoadData = true
        pageNumber -= 1
        loadSavedSearch(true)
    }
    
    //MARK: Private Functions
    
    fileprivate func loadSavedSearch(_ shouldAppend: Bool = false) {
        // Reload the list
        searchListCollectionView.reloadData()
        guard shouldLoadData else {
            updatePanelContent()
            return
        }
        
        hud.show(animated: true)
        savedSearchPanel.loadSavedSearch(pageNumber, { [weak self] (result, error) in
            self?.hud.hide(animated: true)
            
            // Check for Errors
            // Handle the response
            guard error == nil else {
                // Show the Error here
                DLog(error?.localizedDescription)
                self?.updatePanelContent()
                if let errorDesc = error?.localizedDescription {
                    self?.showNoItemsAvailable(errorDesc)
                } else {
                    self?.showNoItemsAvailable()
                }
                
                self?.resetPanel()

                return
            }
            
            if let savedSearchResult = result as? [SavedSearch] {
                
                savedSearchResult.count <= 0 ? self?.showNoItemsAvailable() : self?.hideNoItemsAvailable()
                
                for searchObj in savedSearchResult {
                    searchObj.keys = self?.savedSearchPanel.columns ?? []
                    self?.updateColumnWidthIfNeeded()
                    searchObj.columnsWidth = self?.generatedColumnsWidth() ?? []
                }
            }
            
            self?.updateUI()
            self?.shouldLoadData = false
            self?.searchListCollectionView.reloadData()
            
            self?.customTemplateDataProvider.dataSource = self?.dataSource ?? []
            self?.customTemplateCollectionView?.reloadData()

        })
    }
    
    fileprivate func updateUI() {
        
        nextButton.isEnabled = true
        previousButton.isEnabled = true

        if pageNumber >= (totalNumberOfPages - 1) {
            nextButton.isEnabled = false
        }
        if pageNumber <= 0 {
            previousButton.isEnabled = false
        }

        guard totalNumberOfPages > 0 else {
            pageNumberLabel.text = ""
            return
        }
        let pageNo = pageNumber + 1
        let pageStartNumber = (SavedSearchPanel.Constant.pageSize * pageNumber) + 1
        let pageEndNumber = SavedSearchPanel.Constant.pageSize * pageNo

        let startPageNumber = NSNumber(value: pageStartNumber).formattedWithSeparator
        let endPageNumber = NSNumber(value: pageEndNumber).formattedWithSeparator
        let totalSearchCount = NSNumber(value: savedSearchPanel.totalSavedSearchCount).formattedWithSeparator

        if pageEndNumber > savedSearchPanel.totalSavedSearchCount {
            pageNumberLabel.text = "\(startPageNumber)-\(totalSearchCount) / \(totalSearchCount)"
        } else {
            pageNumberLabel.text = "\(startPageNumber)-\(endPageNumber) / \(totalSearchCount)"
        }
    }
    
    fileprivate func showSavedSearchDetails(_ sourceView: UIView, savedSearch: SavedSearch) {
        let popOverContent = StoryboardManager.shared.storyBoard(.savedSearch).instantiateViewController(withIdentifier: ViewControllerIdentifiers.savedSearchPopOverViewController) as? SavedSearchPopOverViewController ?? SavedSearchPopOverViewController()
        
        popOverContent.savedSearch = savedSearch
        
        if let windowImage = UIApplication.appKeyWindow?.capture() {
             popOverContent.backgroundImage = windowImage
        }
        
        popOverContent.modalPresentationStyle = .overCurrentContext

        present(popOverContent, animated: true, completion: nil)
    }

    fileprivate func generatedColumnsWidth() -> [CGFloat] {
        var eachColumnWidthArray: [CGFloat] = []
        for _ in savedSearchPanel.columns {
            eachColumnWidthArray.append(eachColumnWidth)
        }
        return eachColumnWidthArray
    }
    
    fileprivate func calculatedTotalWidth() -> CGFloat {
        let spacing = CGFloat(spacingBetweenColumn * savedSearchPanel.columns.count)
        let totalWidth = generatedColumnsWidth().reduce(0, {$0 + $1}) + spacing
        return totalWidth
    }
    
    /// If the total width is less than the panel width then equally devide the column width
    fileprivate func updateColumnWidthIfNeeded() {
        
        if calculatedTotalWidth() <= view.frame.size.width {
            let spacing  = CGFloat(spacingBetweenColumn * savedSearchPanel.columns.count )
            eachColumnWidth = (view.frame.size.width - spacing) / CGFloat(savedSearchPanel.columns.count)
        }
    }
    
}

extension SavedSearchListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count > 0 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.savedSearchCollectionViewCell, for: indexPath) as? SavedSearchCollectionViewCell
        cell?.dataSource = dataSource
        cell?.cellSelectionBlock = { [weak self] (cell, selectedSavedSearch) in
            // Show Pop over
            self?.showSavedSearchDetails(self?.view ?? UIView() , savedSearch: selectedSavedSearch)
        }
        cell?.cellLongPressBlock = { [weak self] (cell, filter) in
            // Apply filter
            guard let strongSelf = self else { return }
            if !Session.shared.containsFilter(filter) {
                strongSelf.filterAction?(strongSelf, filter)
            }

        }
        
        cell?.didScrollToBoundary = didScrollToBoundary
        
        return cell ?? UICollectionViewCell()
    }
}

extension SavedSearchListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: calculatedTotalWidth(), height: collectionView.frame.size.height)
    }
}

extension SavedSearchListViewController {
    struct CellIdentifiers {
        static let savedSearchCollectionViewCell    = "SavedSearchCollectionViewCell"
        static let CustomCardCell  =   "CustomCardCell"
    }
    
    struct NibName {
        static let savedSearchCollectionViewCell    = "SavedSearchCollectionViewCell"
    }

    struct ViewControllerIdentifiers {
        static let savedSearchPopOverViewController = "SavedSearchPopOverViewController"
    }
    
    struct LayoutIdentifiers {
        static let profileCardLayoutDark = "ProfileCardCollectionViewCell-Dark.xml"
    }
}
