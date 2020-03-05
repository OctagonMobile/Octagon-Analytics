//
//  FiltersInfoView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 8/18/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit

typealias DrillDownMultiFilterActionBlock = (_ sender: UIButton, _ filterItem: [FilterProtocol]?) -> Void

class FiltersInfoView: UIView {

    var drillDownAction: DrillDownMultiFilterActionBlock?

    @IBOutlet weak var blurrView: UIVisualEffectView!
    @IBOutlet weak var drillDownButton: UIButton!
    @IBOutlet weak var listTable: UITableView!
    
    private var receivedFilterItems: [FilterProtocol]?

    private var selectedFilterItems: [FilterProtocol]?

    private var drillDownTitleColor: UIColor {
        switch CurrentTheme {
        case .light: return .white
        case .dark: return CurrentTheme.headerViewBackground
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialConfiguration()
    }
    //MARK: Private Functions
    private func initialConfiguration() {
        
        listTable.register(UINib(nibName: CellIdentifiers.filterInfoTableViewCell, bundle: Bundle.main), forCellReuseIdentifier: CellIdentifiers.filterInfoTableViewCell)

        blurrView.isHidden = CurrentTheme.isDarkTheme
        style(.shadow(4.0, offset: CGSize(width: 0.0, height: 2.0), opacity: 1.0))
        blurrView.style(.roundCorner(4.0, 0.0, .clear))

        backgroundColor = CurrentTheme.darkBackgroundColorSecondary
        drillDownButton.style(CurrentTheme.headLineTextStyle(drillDownTitleColor))
        drillDownButton.setTitleColor(CurrentTheme.secondaryTitleColor, for: .highlighted)
        drillDownButton.style(.roundCorner(3.0, 1.0, UIColor.white))
        drillDownButton.backgroundColor = CurrentTheme.drillDownButtonBackgroundColor
        let drillIconName = CurrentTheme.isDarkTheme ? "DrillDown-Dark" : "DrillDownWhite"
        drillDownButton.setImage(UIImage(named: drillIconName), for: .normal)

        listTable.delegate = self
        listTable.dataSource = self
    }
    
    func updateDetails(_ selectedItems: [FilterProtocol]?) {
        self.receivedFilterItems = selectedItems
        self.selectedFilterItems = selectedItems
    }
    
    @IBAction func drillDownAction(_ sender: UIButton) {
        drillDownAction?(sender, selectedFilterItems)
    }
}

extension FiltersInfoView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receivedFilterItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.filterInfoTableViewCell) as? FilterInfoTableViewCell else { return UITableViewCell() }
        
        if let filter = receivedFilterItems?[indexPath.row] {
            let isIncluded = selectedFilterItems?.contains(where: { $0.isEqual(filter)} ) ?? false
            cell.setup(filter, isIncluded: isIncluded)
            
            cell.checkBoxActionBlock = {[weak self] (sender, filter, isSelected) in
                guard let selectedFilter = filter else { return }
                if isSelected {
                    self?.selectedFilterItems?.append(selectedFilter)
                } else {
                    self?.selectedFilterItems = self?.selectedFilterItems?.filter({ !$0.isEqual(selectedFilter) })
                }
                self?.drillDownButton.isEnabled = self?.selectedFilterItems?.count ?? 0 > 0
            }
        }
        
        return cell
    }
}

extension FiltersInfoView {
    struct CellIdentifiers {
        static let filterInfoTableViewCell = "FilterInfoTableViewCell"
    }
}

class DrillDownButton: UIButton {
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                let alpha: CGFloat = CurrentTheme.isDarkTheme ? 1.0 : 0.1
                backgroundColor = CurrentTheme.lightBackgroundColor.withAlphaComponent(alpha)
                style(.roundCorner(3.0, 0.0, UIColor.clear))
            } else {
                backgroundColor = CurrentTheme.drillDownButtonBackgroundColor
                style(.roundCorner(3.0, 1.0, UIColor.white))
            }
            super.isHighlighted = newValue
        }

    }
}
