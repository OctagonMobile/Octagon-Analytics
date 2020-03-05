//
//  ControlsViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ControlsViewController: PanelBaseViewController {

    private var controlsFiltersList: [FilterProtocol]   =   []
    private var controlsList: [Control] {
        return (panel?.visState as? InputControlsVisState)?.controls ?? []
    }
    
    private var dataSource: [ControlsWidgetBase]    =   []
    
    //MARK: Outlets
    @IBOutlet weak var controlsCollectionView: UICollectionView!
    @IBOutlet weak var clearFormButton: UIButton!
    @IBOutlet weak var cancelChangesButton: UIButton!
    @IBOutlet weak var applyChangesButton: UIButton!
    
    //MARK: Overridden Functions
    override func setupPanel() {
        super.setupPanel()
              
        initialSetup()
        controlsCollectionView.dataSource = self
        controlsCollectionView.delegate = self
                
        clearFormButton.layer.cornerRadius = 5.0
        cancelChangesButton.layer.cornerRadius = 5.0
        applyChangesButton.layer.cornerRadius = 5.0
        
        applyChangesButton.backgroundColor = CurrentTheme.controlsApplyButtonBackgroundColor
        applyChangesButton.setTitleColor(CurrentTheme.controlsApplyButtonTitleColor, for: .normal)
        applyChangesButton.setTitleColor(CurrentTheme.controlsApplyButtonTitleColor.withAlphaComponent(0.3), for: .disabled)

        clearFormButton.backgroundColor = CurrentTheme.headerViewBackgroundColorSecondary
        clearFormButton.setTitleColor(CurrentTheme.controlsApplyButtonBackgroundColor, for: .normal)
        clearFormButton.setTitleColor(CurrentTheme.controlsApplyButtonBackgroundColor.withAlphaComponent(0.3), for: .disabled)
        clearFormButton.layer.borderColor = CurrentTheme.controlsApplyButtonBackgroundColor.cgColor
        clearFormButton.layer.borderWidth = CurrentTheme.isDarkTheme ? 0.0 : 1.0

        cancelChangesButton.backgroundColor = CurrentTheme.headerViewBackgroundColorSecondary
        cancelChangesButton.setTitleColor(CurrentTheme.controlsApplyButtonBackgroundColor, for: .normal)
        cancelChangesButton.setTitleColor(CurrentTheme.controlsApplyButtonBackgroundColor.withAlphaComponent(0.3), for: .disabled)
        cancelChangesButton.layer.borderColor = CurrentTheme.controlsApplyButtonBackgroundColor.cgColor
        cancelChangesButton.layer.borderWidth = CurrentTheme.isDarkTheme ? 0.0 : 1.0
    }
    
//    override func loadChartData() {
//        // nothing to load from server
//    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        
        // Supporting only one Type
        guard let controlsWidget = dataSource.first else { return }
        
        if controlsWidget.control.type == .range {
            (controlsWidget as? RangeControlsWidget)?.minValue = Float((panel as? ControlsPanel)?.minAgg ?? 0)
            (controlsWidget as? RangeControlsWidget)?.maxValue = Float((panel as? ControlsPanel)?.maxAgg ?? 0)
        } else {
            (controlsWidget as? ListControlsWidget)?.list = (panel as? ControlsPanel)?.buckets ?? []
        }
        controlsCollectionView.reloadData()
    }
    
    private func initialSetup() {
        dataSource.removeAll()
        
        guard let controlObj = controlsList.first else { return }
        
        let appliedFilter = Session.shared.appliedFilters.filter({ $0.fieldName == controlObj.fieldName}).first

        if controlObj.type == .range {
            let rangeControl = RangeControlsWidget(controlObj)
            //Update the Range selected based on applied filter
            if let ranges: [String] = (appliedFilter as? SimpleFilter)?.fieldValue.components(separatedBy: "-"),
                ranges.count > 1 {
                rangeControl.selectedMinValue = Float(ranges.first!)
                rangeControl.selectedMaxValue = Float(ranges.last!)
            }
            dataSource.append(rangeControl)
        } else {
            let listControl = ListControlsWidget(controlObj, list: [])
            dataSource.append(listControl)
        }
    }
    
    private func applyFilters() {
        
        for controlsObj in dataSource {
            let control = controlsObj.control
            if control.type == .range {
                let rangeControls = controlsObj as? RangeControlsWidget
                guard let min = rangeControls?.selectedMinValue, let max = rangeControls?.selectedMaxValue else { continue }
                
                let matchedFilter = controlsFiltersList.filter({ $0.fieldName == control.fieldName}).first
                if matchedFilter == nil {
                    let filter = SimpleFilter(fieldName: control.fieldName, fieldValue: "\(min)-\(max)", type: BucketType.range)
                    controlsFiltersList.append(filter)
                } else {
                    controlsFiltersList.removeAll(where: { $0.fieldName == matchedFilter?.fieldName })
                    controlsFiltersList.append(matchedFilter!)
                }
                
            } else {
                // create filters for List
            }
        }
        
        // Call multiFilterAction
        controlsFiltersList.forEach { (filter) in
            
            if Session.shared.containsFilter(filter) {
                Session.shared.appliedFilters.removeAll(where: { $0.fieldName == filter.fieldName })
            }
            
            filterAction?(self, filter)
        }
        
        controlsCollectionView.reloadData()
    }
    
    //MARK: Button Actions
    @IBAction func clearFormButtonAction(_ sender: Any) {
        // Reset to 0
        controlsFiltersList.removeAll()
        for controlObj in dataSource {
            if controlObj.control.type == .range {
                (controlObj as? RangeControlsWidget)?.selectedMinValue = nil
                (controlObj as? RangeControlsWidget)?.selectedMaxValue = nil
            }
        }
        controlsCollectionView?.reloadData()
        clearFormButton.isEnabled = false
        applyChangesButton.isEnabled = false
    }
    
    @IBAction func cancelChangesAction(_ sender: Any) {
    }
    
    @IBAction func applyChangesAction(_ sender: Any) {
        applyFilters()
    }
}

extension ControlsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let controlWidget = dataSource[indexPath.row]
        let controlType = controlWidget.control.type
        let cellId = controlType == .range ? CellIdentifiers.rangeControlsCell : CellIdentifiers.listControlsCell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ControlsBaseCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if controlType == .range {
            (cell as? RangeControlsCollectionViewCell)?.rangeSelectionUpdateBlock = { [weak self] (sender, max, min) in
                self?.clearFormButton.isEnabled = true
                self?.applyChangesButton.isEnabled = true
            }
        }
        
        cell.controlWidget = controlWidget
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let controlWidget = dataSource[indexPath.row]
        guard controlWidget.control.type == .list, (controlWidget as? ListControlsWidget)?.list.count ?? 0 > 0,
            let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }

        let popOverContent = StoryboardManager.shared.storyBoard(.search).instantiateViewController(withIdentifier: ViewControllerIdentifiers.controlsListPopOverViewController) as? ControlsListPopOverViewController ?? ControlsListPopOverViewController()
        popOverContent.selectionBlock = { (sender, selectedList) in
            //Update UI
        }
        popOverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = popOverContent.popoverPresentationController
        popover?.backgroundColor = CurrentTheme.cellBackgroundColorPair.last?.withAlphaComponent(1.0)
        
        if !isIPhone {
            popOverContent.preferredContentSize = CGSize(width: 200, height: 300)
            popover?.delegate = self
            popover?.permittedArrowDirections = .any
            popover?.sourceRect = cell.frame
            popover?.sourceView = cell
        }
        
        rootViewController.present(popOverContent, animated: true, completion: nil)
    }
}

extension ControlsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
}

extension ControlsViewController {
    struct CellIdentifiers {
        static let rangeControlsCell    =   "RangeControlsCollectionViewCell"
        static let listControlsCell     =   "ListControlsCollectionViewCell"
    }
    
    struct ViewControllerIdentifiers {
        static let controlsListPopOverViewController     =   "ControlsListPopOverViewController"
    }
}
