//
//  ControlsViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class ControlsViewController: PanelBaseViewController {
    
    //MARK: Outlets
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelChangesButton: UIButton!
    @IBOutlet weak var applyChangesButton: UIButton!
    
    //MARK: Private
    private var control: Control? {
        return (panel?.visState as? InputControlsVisState)?.controls.first
    }

    private var rangeControlsView: RangeControlsView?
    private var listControlsView: ListOptionControlsView?
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        applyChangesButton.isEnabled = false
        applyChangesButton.layer.cornerRadius = 5.0
        applyChangesButton.backgroundColor = CurrentTheme.controlsApplyButtonBackgroundColor
        applyChangesButton.setTitleColor(CurrentTheme.controlsApplyButtonTitleColor, for: .normal)
        applyChangesButton.setTitleColor(CurrentTheme.controlsApplyButtonTitleColor.withAlphaComponent(0.3), for: .disabled)

        func configureButton(_ button: UIButton) {
            button.layer.cornerRadius = 5.0
            button.backgroundColor = CurrentTheme.headerViewBackgroundColorSecondary
            button.setTitleColor(CurrentTheme.controlsApplyButtonBackgroundColor, for: .normal)
            button.setTitleColor(CurrentTheme.controlsApplyButtonBackgroundColor.withAlphaComponent(0.3), for: .disabled)
            button.layer.borderColor = CurrentTheme.controlsApplyButtonBackgroundColor.cgColor
            button.layer.borderWidth = CurrentTheme.isDarkTheme ? 0.0 : 1.0
            button.isEnabled = false
        }
        configureButton(resetButton)
        configureButton(cancelChangesButton)
    }
    
    override func setupPanel() {
        super.setupPanel()
        holderView.subviews.forEach({ $0.removeFromSuperview() })
        
        //Setup Panel
        if control?.type == .range {
            configureRangeControls()
        } else {
            configureListControls()
        }
    }
    
    private func configureRangeControls() {
        guard let rangeControlsView = Bundle.main.loadNibNamed(NibNames.rangeControlsView, owner: self, options: nil)?.first as? RangeControlsView else { return }
        self.rangeControlsView = rangeControlsView
        rangeControlsView.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(rangeControlsView)
        setupConstraintsForControlsView(rangeControlsView)
        
        rangeControlsView.rangeSelectionUpdateBlock = { [weak self] (sender, max, min) in
            self?.enableAllButtons()
        }
    }
    
    private func configureListControls() {
        guard let listControlsView = Bundle.main.loadNibNamed(NibNames.listOptionControlsView, owner: self, options: nil)?.first as? ListOptionControlsView else { return }
        self.listControlsView = listControlsView
        listControlsView.translatesAutoresizingMaskIntoConstraints = false
        holderView.addSubview(listControlsView)
        setupConstraintsForControlsView(listControlsView)
    }
    
    private func setupConstraintsForControlsView(_ controlsView: UIView) {
        var constraints = [NSLayoutConstraint]()
        let views: [String: UIView] = ["holderView": holderView, "controlsView": controlsView]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[controlsView]-0-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[controlsView]-0-|", options: [], metrics: nil, views: views)
        holderView?.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
    }
    
    override func updatePanelContent() {
        super.updatePanelContent()
        
        guard let control = control else { return }

        if control.type == .range {
            let minimum = Float((panel as? ControlsPanel)?.minAgg ?? 0)
            let max = Float((panel as? ControlsPanel)?.maxAgg ?? 0)
            rangeControlsView?.rangeControlWidget = RangeControlsWidget(control, min: minimum, max: max)
        } else {
            let list = (panel as? ControlsPanel)?.chartContentList ?? []
            listControlsView?.listControlWidget = ListControlsWidget(control, list: list)
            listControlsView?.dropDownActionBlock = { [weak self] sender in
                self?.showDropDownList()
            }
        }
    }
    
    private func showDropDownList() {
        
        guard let listControlsView = listControlsView,
            let window = UIApplication.shared.keyWindow,
            let rootViewController = window.rootViewController else { return }

        let popOverContent = StoryboardManager.shared.storyBoard(.search).instantiateViewController(withIdentifier: ViewControllerIdentifiers.controlsListPopOverViewController) as? ControlsListPopOverViewController ?? ControlsListPopOverViewController()

        // Generate the List options object using data source
        func generateListOptions() -> [ControlsListOption] {
            guard let selectedList = listControlsView.listControlWidget?.selectedList else { return []}
            let list = panel?.chartContentList.compactMap({ (item) -> ControlsListOption? in
                let option = ControlsListOption()
                option.data = item
                option.isSelected = selectedList.contains(where: { $0.key == item.key })
                return option
            }) ?? []
            return list
        }

        popOverContent.list = generateListOptions()
        popOverContent.multiSelectionEnabled = listControlsView.listControlWidget?.control.listOptions?.multiselect ?? false
        popOverContent.selectionBlock = { [weak self] (sender, selectedList) in
            //Update UI
            listControlsView.listControlWidget?.selectedList = selectedList.compactMap({ $0.data })
            listControlsView.updateContent()
            let shouldEnableButtons = selectedList.count > 0
            self?.enableAllButtons(shouldEnableButtons)
        }
        popOverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = popOverContent.popoverPresentationController
        popover?.backgroundColor = CurrentTheme.cellBackgroundColorPair.last?.withAlphaComponent(1.0)

        if !isIPhone {
            guard let holderView = listControlsView.holderView else { return }
            popOverContent.preferredContentSize = CGSize(width: holderView.bounds.width, height: 300)
            popover?.delegate = self

            let showRect    = listControlsView.convert(holderView.frame, to: view)
            popover?.sourceRect = showRect
            popover?.sourceView = view
        }
        rootViewController.present(popOverContent, animated: true, completion: nil)
    }
    
    private func enableAllButtons(_ enable: Bool = true) {
        resetButton.isEnabled = enable
        cancelChangesButton.isEnabled = enable
        applyChangesButton.isEnabled = enable
    }
    
    private func applyFilters() {
        
        guard let control = control else { return }

        var filtersList: [FilterProtocol] = []
        if control.type == .range {
            let rangeControls = rangeControlsView?.rangeControlWidget
            guard let min = rangeControls?.selectedMinValue, let max = rangeControls?.selectedMaxValue else { return }
            let filter = SimpleFilter(fieldName: control.fieldName, fieldValue: "\(min)-\(max)", type: BucketType.range)
            filtersList.append(filter)
        } else {
            let listControls = listControlsView?.listControlWidget
            guard let fieldValue = listControls?.selectedList.compactMap({ $0.key }).joined(separator: ",") else { return }
            let filter = SimpleFilter(fieldName: control.fieldName, fieldValue: fieldValue, type: BucketType.terms)
            filtersList.append(filter)
        }
        
        multiFilterAction?(self, filtersList)
    }

    //MARK: Button Actions
    @IBAction func resetButtonAction(_ sender: UIButton) {
        if control?.type == .range {
            rangeControlsView?.rangeControlWidget?.selectedMinValue = nil
            rangeControlsView?.rangeControlWidget?.selectedMaxValue = nil
            rangeControlsView?.updateContent()
            
            if rangeControlsView?.rangeControlWidget?.prevSelectedMinValue != nil {
                resetButton.isEnabled = false
                cancelChangesButton.isEnabled = true
                applyChangesButton.isEnabled = true
            } else {
                enableAllButtons(false)
            }
        } else {
            listControlsView?.listControlWidget?.selectedList = []
            listControlsView?.updateContent()
            
            if listControlsView?.listControlWidget?.prevSelectedList != nil {
                resetButton.isEnabled = false
                cancelChangesButton.isEnabled = true
                applyChangesButton.isEnabled = true
            } else {
                enableAllButtons(false)
            }
        }
        
    }
    
    @IBAction func cancelChangesButtonAction(_ sender: UIButton) {
        if control?.type == .range,
            let rangeWidget = rangeControlsView?.rangeControlWidget {
            rangeWidget.selectedMinValue = rangeWidget.prevSelectedMinValue
            rangeWidget.selectedMaxValue = rangeWidget.prevSelectedMaxValue
            rangeControlsView?.updateContent()
            
            if rangeControlsView?.rangeControlWidget?.prevSelectedMinValue != nil {
                resetButton.isEnabled = true
                cancelChangesButton.isEnabled = false
                applyChangesButton.isEnabled = false
            } else {
                enableAllButtons(false)
            }
        } else if control?.type == .list, let listWidget = listControlsView?.listControlWidget {
            listWidget.selectedList = listWidget.prevSelectedList ?? []
            listControlsView?.updateContent()
            
            if listControlsView?.listControlWidget?.prevSelectedList != nil  {
                resetButton.isEnabled = true
                cancelChangesButton.isEnabled = false
                applyChangesButton.isEnabled = false
            } else {
                enableAllButtons(false)
            }
        }
    }
    
    @IBAction func applychangesButtonAction(_ sender: UIButton) {
        
        if control?.type == .range, let rangeWidget = rangeControlsView?.rangeControlWidget {
            rangeWidget.prevSelectedMinValue = rangeWidget.selectedMinValue
            rangeWidget.prevSelectedMaxValue = rangeWidget.selectedMaxValue
            applyChangesButton.isEnabled = false
            cancelChangesButton.isEnabled = false
        } else if control?.type == .list, let listWidget = listControlsView?.listControlWidget {
            listWidget.prevSelectedList = listWidget.selectedList
            applyChangesButton.isEnabled = false
            cancelChangesButton.isEnabled = false
        }
        
        //Apply filters
        applyFilters()
    }
    
}

extension ControlsViewController {
    struct NibNames {
        static let rangeControlsView        =   "RangeControlsView"
        static let listOptionControlsView   =   "ListOptionControlsView"
    }
    
    struct ViewControllerIdentifiers {
        static let controlsListPopOverViewController    =   "ControlsListPopOverViewController"
    }
}
