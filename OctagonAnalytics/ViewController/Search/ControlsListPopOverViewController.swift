//
//  ControlsListPopOverViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 3/3/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ControlsListPopOverViewController: BaseViewController {
    
    public typealias ControlsListSelectionBlock = (_ sender: ControlsListPopOverViewController,_ selectedList: [ControlsListOption]) -> Void
    
    var selectionBlock: ControlsListSelectionBlock?
    var multiSelectionEnabled: Bool =   true
    
    var list: [ControlsListOption]  =   [] {
        didSet {
            controlsListView?.reloadData()
        }
    }
    
    @IBOutlet weak var doneButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton?
    @IBOutlet weak var controlsListView: UITableView?

    //MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        controlsListView?.dataSource = self
        controlsListView?.delegate = self
        controlsListView?.backgroundColor = .clear
        view.backgroundColor = CurrentTheme.cellBackgroundColor
        
        doneButton?.setTitleColor(CurrentTheme.controlsApplyButtonBackgroundColor, for: .normal)
        doneButton?.style(.roundCorner(5.0, 1.0, CurrentTheme.controlsApplyButtonBackgroundColor))
        doneButtonHeightConstraint?.constant = (isIPhone && multiSelectionEnabled) ? 45 : 0
    }
    
    func selectControlOptions(_ selectedDataList: [ControlsListOption], shouldDismiss: Bool = true) {
        if shouldDismiss {
            dismiss(animated: true) { [weak self] in
                guard let strongSelf = self else { return }
                self?.selectionBlock?(strongSelf, selectedDataList)
            }
        } else {
            selectionBlock?(self, selectedDataList)
        }
    }
    
    //MARK: Button Action
    @IBAction func doneButtonAction(_ sender: Any) {
        let selectedList = list.filter({ $0.isSelected })
        selectControlOptions(selectedList, shouldDismiss: true)
    }
}

extension ControlsListPopOverViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.controlsListTableViewCell, for: indexPath) as? ControlsListTableViewCell else {
            return UITableViewCell()
        }
        cell.multiSelectionEnabled = multiSelectionEnabled
        cell.controlOption = list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard multiSelectionEnabled else {
            selectControlOptions([list[indexPath.row]])
            return
        }
        
        list[indexPath.row].isSelected = !list[indexPath.row].isSelected
        
        let selectedList = list.filter({ $0.isSelected })
        selectControlOptions(selectedList, shouldDismiss: false)
        tableView.reloadData()
    }
}

extension ControlsListPopOverViewController {
    struct CellIdentifiers {
        static let controlsListTableViewCell    =   "ControlsListTableViewCell"
    }
}


class ControlsListTableViewCell: UITableViewCell {
    
    var multiSelectionEnabled: Bool =   true {
        didSet {
            checkBoxWidthConstraint.constant = multiSelectionEnabled ? 20 : 0
        }
    }
    
    var controlOption: ControlsListOption? {
        didSet {
            updateCell()
        }
    }
    
    @IBOutlet weak var checkBoxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    //MARK: Life Cycles
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectdImageName = CurrentTheme.isDarkTheme ? "Checkbox-Selected-Dark" : "Checkbox-Selected"
        let selectedImage = UIImage(named: selectdImageName)
        checkBoxButton.setImage(selectedImage, for: .selected)
        
        let normalImageName = CurrentTheme.isDarkTheme ? "Checkbox-Normal-Dark" : "Checkbox-Normal"
        let image = UIImage(named: normalImageName)
        checkBoxButton.setImage(image, for: .normal)
        
        titleLabel.textColor = CurrentTheme.titleColor
    }
    
    func updateCell() {
        titleLabel.text = controlOption?.data?.key
        backgroundColor = controlOption?.isSelected == true ? CurrentTheme.popOverListSelectionColor : .clear
        backgroundView?.backgroundColor = controlOption?.isSelected == true ? CurrentTheme.popOverListSelectionColor : .clear

        checkBoxButton.isSelected = controlOption?.isSelected ?? false
    }
}

class ControlsListOption {
    var isSelected: Bool    = false
    var data: ChartContent?
}
