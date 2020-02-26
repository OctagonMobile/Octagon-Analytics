//
//  ControlsViewController.swift
//  KibanaGo
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
    
    //MARK: Outlets
    @IBOutlet weak var controlsCollectionView: UICollectionView!
    @IBOutlet weak var clearFormButton: UIButton!
    @IBOutlet weak var cancelChangesButton: UIButton!
    @IBOutlet weak var applyChangesButton: UIButton!
    
    //MARK: Overridden Functions
    override func setupPanel() {
        super.setupPanel()
        
        controlsCollectionView.dataSource = self
        controlsCollectionView.delegate = self
        
        clearFormButton.backgroundColor = CurrentTheme.standardColor
        cancelChangesButton.backgroundColor = CurrentTheme.standardColor
        applyChangesButton.backgroundColor = CurrentTheme.standardColor
        
        clearFormButton.layer.cornerRadius = 5.0
        cancelChangesButton.layer.cornerRadius = 5.0
        applyChangesButton.layer.cornerRadius = 5.0


        clearFormButton.style(CurrentTheme.textStyleWith(clearFormButton.titleLabel?.font.pointSize ?? 20, weight: .regular, color: CurrentTheme.secondaryTitleColor))
        cancelChangesButton.style(CurrentTheme.textStyleWith(cancelChangesButton.titleLabel?.font.pointSize ?? 20, weight: .regular, color: CurrentTheme.secondaryTitleColor))
        applyChangesButton.style(CurrentTheme.textStyleWith(applyChangesButton.titleLabel?.font.pointSize ?? 20, weight: .regular, color: CurrentTheme.secondaryTitleColor))

    }
    
    override func loadChartData() {
        // nothing to load from server
    }
    
    //MARK: Button Actions
    @IBAction func clearFormButtonAction(_ sender: Any) {
    }
    
    @IBAction func cancelChangesAction(_ sender: Any) {
    }
    
    @IBAction func applyChangesAction(_ sender: Any) {

        for filter in controlsFiltersList {
            if !Session.shared.containsFilter(filter) {
                filterAction?(self, filter)
            }
        }
    }
}

extension ControlsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controlsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let control = controlsList[indexPath.row]
        let cellId = control.type == .range ? CellIdentifiers.rangeControlsCell : CellIdentifiers.listControlsCell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ControlsBaseCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.control = control
        
        switch control.type {
        case .range:
            (cell as? RangeControlsCollectionViewCell)?.rangeSelectionBlock = { [weak self] (control, min, max) in
                let filter = SimpleFilter(fieldName: control!.fieldName, fieldValue: "\(min)-\(max)", type: BucketType.range)
                let matchedFilter = self?.controlsFiltersList.filter({ $0.fieldName == filter.fieldName }).first
                if matchedFilter == nil {
                    self?.controlsFiltersList.append(filter)
                } else {
                    self?.controlsFiltersList.removeAll(where: { $0.fieldName == filter.fieldName })
                    self?.controlsFiltersList.append(filter)
                }
            }
        case .list:
            DLog("Control Type = List")
        }
        
        return cell
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
}
