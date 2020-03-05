//
//  CanvasListViewController.swift
//  KibanaGo
//
//  Created by Rameez on 11/4/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import MBProgressHUD

class CanvasListViewController: BaseViewController {

    var canvasLoader: CanvasLoader      =   CanvasLoader()
    
    private var hud: MBProgressHUD?
    private var refreshControl: UIRefreshControl?
    private var searchText: String      =   ""
    private var dataSource: [Canvas]    =   []
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var canvasListCollectionView: UICollectionView?
    
    //MARK: Life Cyccle
    override func viewDidLoad() {
        super.viewDidLoad()

        title   =   "Canvas List".localiz()
        
        canvasListCollectionView?.delegate = self
        canvasListCollectionView?.dataSource = self
        
        canvasListCollectionView?.register(UINib(nibName: CellId.dashboardListHeaderView, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellId.dashboardListHeaderView)

        infoLabel.text  =   "NoCanvasFound".localiz()
        infoLabel.isHidden = true
        infoLabel.style(CurrentTheme.textStyleWith(infoLabel.font.pointSize, weight: .regular, color: CurrentTheme.standardColor))
        configureRefreshControl()
        loadCanvasList()
    }

    override func leftBarButtons() -> [UIBarButtonItem] {
        return []
    }

    //MARK: Refresh Control Config
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        let refreshControlTitle = NSAttributedString(string: "Loading...".localiz(), attributes: [NSAttributedString.Key.foregroundColor : CurrentTheme.titleColor])
        refreshControl?.attributedTitle = refreshControlTitle
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl?.tintColor = CurrentTheme.standardColor
        
        guard let refresh = refreshControl else { return }
        canvasListCollectionView?.addSubview(refresh)
    }
    
    @objc private func refresh(_ control: UIRefreshControl) {
        loadCanvasList(false)
    }

    //MARK: Load Canvas list
    private func loadCanvasList(_ showLoader: Bool = true) {
        
        if showLoader {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        }
        canvasLoader.loadCanvasList { [weak self] (res, error) in
            
            self?.refreshControl?.endRefreshing()
            self?.hud?.hide(animated: true)
            
            self?.filterCanvasList()

            guard error == nil else {
                self?.showAlert(error?.localizedDescription)
                return
            }
        }
    }
    
    private func filterCanvasList() {
        guard !searchText.isEmpty else {
            dataSource = canvasLoader.canvasList
            canvasListCollectionView?.reloadSections(IndexSet(integer: 1))
            infoLabel.isHidden = dataSource.count > 0
            return
        }
        
        dataSource.removeAll()
        dataSource = canvasLoader.canvasList.filter { (item) -> Bool in
            item.name.lowercased().range(of: self.searchText.lowercased()) != nil
        }
        canvasListCollectionView?.reloadSections(IndexSet(integer: 1))
        infoLabel.isHidden = dataSource.count > 0
    }

}

extension CanvasListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // First section contains only the search bar
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section != 0 else { return 0 }
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellId.canvasListCollectionViewCell, for: indexPath) as? CanvasListCollectionViewCell else { return UICollectionViewCell() }
        cell.canvas = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CanvasListCollectionViewCell else { return }
        // Update UI here since the custom font size based on size class doesn't work unless cell is ready
        cell.updateUI()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let canvasController = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: StoryboardId.canvasViewController) as? CanvasViewController else { return }
        canvasController.canvas = dataSource[indexPath.row]
        navigationController?.pushViewController(canvasController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard indexPath.section == 0 else { return UICollectionReusableView() }

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CellId.dashboardListHeaderView, for: indexPath) as? DashboardListHeaderView else { return UICollectionReusableView() }
        header.searchClicked = { [weak self] (text, sender) in
            self?.searchText = text ?? ""
            self?.filterCanvasList()
        }
        
        return header
    }
}

extension CanvasListViewController: UICollectionViewDelegateFlowLayout {
    
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

extension CanvasListViewController {
    struct CellId {
        static let canvasListCollectionViewCell =   "CanvasListCollectionViewCell"
        static let dashboardListHeaderView      =   "DashboardListHeaderView"
    }
    
    struct StoryboardId {
        static let canvasViewController =   "CanvasViewController"
    }
}
