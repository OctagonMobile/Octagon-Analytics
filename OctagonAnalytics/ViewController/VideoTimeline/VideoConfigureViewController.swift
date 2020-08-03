//
//  VideoConfigureViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 09/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import Eureka
import SwiftDate
import MBProgressHUD

enum VideoType: String {
    case barChartRace   =   "BarChart Race"
    case vectorMap        =   "Vector Map"
    
    static var all: [VideoType]    =   [.barChartRace, .vectorMap]
}

class VideoConfigureViewController: FormViewController {

    var videoContentLoader  =   VideoContentLoader()
    
    @IBOutlet weak var generateVideoButton: UIButton!
    
    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = CurrentTheme.lightBackgroundColor
        title   =   "Video Configuration".localiz()
        navigationItem.leftBarButtonItems = []
        
        generateVideoButton.style(CurrentTheme.textStyleWith(generateVideoButton.titleLabel?.font.pointSize ?? 20, weight: .semibold, color: CurrentTheme.secondaryTitleColor))
        generateVideoButton.style(.roundCorner(5.0, 0.0))
        generateVideoButton.backgroundColor = CurrentTheme.standardColor

        createForm()
        tableView.tableFooterView = UIView()
        loadIndexPatters()
    }
    
    private func createForm() {
        form +++ Section("")

            
            <<< SegmentedRow<VideoType>() {
                $0.tag      =   FormTag.videoType
                $0.options  =   VideoType.all
                $0.value    =   .barChartRace
                $0.displayValueFor = {
                    guard let type = $0 else { return nil }
                    return type.rawValue
                }
                $0.cellSetup { (cell, row) in
                    cell.segmentedControl.backgroundColor = CurrentTheme.enabledStateBackgroundColor
//                    cell.segmentedControl.selectedSegmentTintColor = CurrentTheme.titleColor
                    cell.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: CurrentTheme.titleColor], for: .normal)
                    cell.segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: CurrentTheme.selectedTitleColor], for: .selected)
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                }
            }
            
            <<< OAPickerInputRow<IndexPattern>() {
                $0.title = "Index Pattern".localiz()
                $0.tag = FormTag.indexPattern
                $0.add(rule: RuleRequired(msg: ErrorMessages.indexPatternError))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.options = videoContentLoader.indexPattersList
                $0.displayValueFor = {
                    guard let indexPattern = $0 else { return nil }
                    return indexPattern.title
                }
                $0.cellSetup { (cell, row) in
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.valueTextField?.style(CurrentTheme.textStyleWith(cell.valueTextField.font!.pointSize, weight: .regular))
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.valueTextField.attributedPlaceholder = NSAttributedString(string: "Select Index Pattern".localiz(), attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.valueTextField?.textColor = CurrentTheme.titleColor

                    if !row.isValid {

                        cell.valueTextField?.textColor = CurrentTheme.errorMessageColor
                        var errors = ""

                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }

                        cell.valueTextField?.text = errors
                        cell.valueTextField?.isHidden = false
                    }

                }
                $0.onChange { (row) in

                    guard let timeFieldRow = self.form.rowBy(tag: FormTag.timeField) as? OAPickerInputRow<IPField>,
                        let fieldRow = self.form.rowBy(tag: FormTag.field) as? OAPickerInputRow<IPField>,
                        let valueToDisplayRow = self.form.rowBy(tag: FormTag.valueToDisplay) as? OAPickerInputRow<IPField>,
                        let selectedIndexPattern = row.value else { return }

                    timeFieldRow.options = selectedIndexPattern.fields.filter({ $0.type == "date"})
                    timeFieldRow.value = nil
                    timeFieldRow.updateCell()
                    
                    fieldRow.options = selectedIndexPattern.fields.filter({ $0.type == "string" && $0.name != "_type" && $0.name != "_index" && $0.name != "_id"})
                    fieldRow.value = nil
                    fieldRow.updateCell()

                    valueToDisplayRow.options = selectedIndexPattern.fields.filter({ $0.type == "number" && $0.name != "_score"})
                    valueToDisplayRow.value = nil
                    valueToDisplayRow.updateCell()

                }
            }
            
            <<< OAPickerInputRow<IPField>() {
                $0.title = "Time Field".localiz()
                $0.tag = FormTag.timeField
                $0.options = []
                $0.add(rule: RuleRequired(msg: ErrorMessages.timeFieldError))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.hidden = Condition.function([FormTag.indexPattern]){ form in
                    if let row = form.rowBy(tag: FormTag.indexPattern) as? OAPickerInputRow<IndexPattern> {
                        return row.value == nil
                    }
                    return false
                }
                $0.displayValueFor = {
                    guard let field = $0 else { return nil }
                    return field.name
                }
                $0.cellSetup { (cell, row) in
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.valueTextField?.style(CurrentTheme.textStyleWith(cell.valueTextField.font!.pointSize, weight: .regular))
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.valueTextField.attributedPlaceholder = NSAttributedString(string: "Select Time Field".localiz(), attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.valueTextField?.textColor = CurrentTheme.titleColor
                    if !row.isValid {
                        
                        cell.valueTextField?.textColor = CurrentTheme.errorMessageColor

                        var errors = ""
                        
                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }
                        
                        cell.valueTextField?.text = errors
                        cell.valueTextField?.isHidden = false
                    }
                }
                $0.onCellSelection { (cell, row) in
                    if row.value == nil {
                        row.value = row.options.first
                        row.updateCell()
                    }
                }
            }

            <<< OAPickerInputRow<IPField>() {
                $0.title = "Field".localiz()
                $0.tag = FormTag.field
                $0.options = []
                $0.add(rule: RuleRequired(msg: ErrorMessages.fieldError))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.hidden = Condition.function([FormTag.indexPattern]){ form in
                    if let row = form.rowBy(tag: FormTag.indexPattern) as? OAPickerInputRow<IndexPattern> {
                        return row.value == nil
                    }
                    return false
                }
                $0.displayValueFor = {
                    guard let field = $0 else { return nil }
                    return field.name
                }
                $0.cellSetup { (cell, row) in
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.valueTextField?.style(CurrentTheme.textStyleWith(cell.valueTextField.font!.pointSize, weight: .regular))
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.valueTextField.attributedPlaceholder = NSAttributedString(string: "Select Field".localiz(), attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.valueTextField?.textColor = CurrentTheme.titleColor
                    if !row.isValid {
                        
                        cell.valueTextField?.textColor = CurrentTheme.errorMessageColor

                        var errors = ""
                        
                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }
                        
                        cell.valueTextField?.text = errors
                        cell.valueTextField?.isHidden = false
                    }
                }
                $0.onCellSelection { (cell, row) in
                    if row.value == nil {
                        row.value = row.options.first
                        row.updateCell()
                    }
                }
            }

            <<< OAPickerInputRow<IPField>() {
                $0.title = "Value To Display".localiz()
                $0.tag = FormTag.valueToDisplay
                $0.options = []
                $0.add(rule: RuleRequired(msg: ErrorMessages.valueToDisplayError))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.hidden = Condition.function([FormTag.indexPattern]){ form in
                    if let row = form.rowBy(tag: FormTag.indexPattern) as? OAPickerInputRow<IndexPattern> {
                        return row.value == nil
                    }
                    return false
                }
                $0.displayValueFor = {
                    guard let field = $0 else { return nil }
                    return field.name
                }
                $0.cellSetup { (cell, row) in
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.valueTextField?.style(CurrentTheme.textStyleWith(cell.valueTextField.font!.pointSize, weight: .regular))
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.valueTextField.attributedPlaceholder = NSAttributedString(string: "Select Value To Display".localiz(), attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.valueTextField?.textColor = CurrentTheme.titleColor
                    if !row.isValid {
                        
                        cell.valueTextField?.textColor = CurrentTheme.errorMessageColor

                        var errors = ""
                        
                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }
                        
                        cell.valueTextField?.text = errors
                        cell.valueTextField?.isHidden = false
                    }
                }
                $0.onCellSelection { (cell, row) in
                    if row.value == nil {
                        row.value = row.options.first
                        row.updateCell()
                    }
                }
            }
            
            <<< StepperRow() {
                $0.title = "Top Count".localiz()
                $0.tag = FormTag.maxCount
                $0.value = Double(videoContentLoader.configContent.topMaxNumber)
                $0.cellSetup { (cell, row) in
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.stepper.minimumValue = 2
                    cell.stepper.maximumValue = 50
                    cell.stepper.setIncrementImage(UIImage(named: "ZoomIn"), for: .normal)
                    cell.stepper.setDecrementImage(UIImage(named: "ZoomOut"), for: .normal)
                    cell.valueLabel.textColor = CurrentTheme.titleColor
                    cell.tintColor = CurrentTheme.titleColor
                }
                $0.cellUpdate { (cell, row) in
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.titleLabel?.text = row.title
                }
                $0.displayValueFor = {
                    guard let val = $0 else { return nil }
                    return "\(Int(val))"
                }

            }
            
            <<< OADateRow() {
                $0.title = "From Date".localiz()
                $0.tag = FormTag.fromDate
                $0.value = videoContentLoader.configContent.fromDate
                $0.cellSetup { (cell, row) in
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.valueTextField?.style(CurrentTheme.textStyleWith(cell.valueTextField.font!.pointSize, weight: .regular))
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.valueTextField.attributedPlaceholder = NSAttributedString(string: "Select From Date".localiz(), attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.valueTextField?.textColor = CurrentTheme.titleColor
                    if let toDateRow = self.form.rowBy(tag: FormTag.toDate) as? OADateRow {
                        toDateRow.minimumDate = row.value
                    }
                }
                $0.onChange { (row) in
                    guard let fromDate = row.value,
                        let toDate = (self.form.rowBy(tag: FormTag.toDate) as? OADateRow)?.value else { return }
                    if let spanRow = self.form.rowBy(tag: FormTag.span) as? OAPickerInputRow<SpanType> {
                        spanRow.options = SpanType.spanTypeListFor(fromDate, toDate: toDate)
                        spanRow.value = nil
                        spanRow.updateCell()
                    }
                }
            }
            
            <<< OADateRow() {
                $0.title = "To Date".localiz()
                $0.tag = FormTag.toDate
                $0.value = videoContentLoader.configContent.toDate
                $0.cellSetup { (cell, row) in
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.valueTextField?.style(CurrentTheme.textStyleWith(cell.valueTextField.font!.pointSize, weight: .regular))
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.valueTextField.attributedPlaceholder = NSAttributedString(string: "Select To Date".localiz(), attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.valueTextField?.textColor = CurrentTheme.titleColor
                    if let fromDateRow = self.form.rowBy(tag: FormTag.fromDate) as? OADateRow {
                        fromDateRow.maximumDate = row.value
                    }
                }
                $0.onChange { (row) in
                    guard let fromDate = (self.form.rowBy(tag: FormTag.fromDate) as? OADateRow)?.value,
                        let toDate = row.value else { return }
                    if let spanRow = self.form.rowBy(tag: FormTag.span) as? OAPickerInputRow<SpanType> {
                        spanRow.options = SpanType.spanTypeListFor(fromDate, toDate: toDate)
                        spanRow.value = nil
                        spanRow.updateCell()
                    }
                }
            }
            
            <<< OAPickerInputRow<SpanType>() {
                $0.title = "Span".localiz()
                $0.tag = FormTag.span
                $0.options = SpanType.spanTypeListFor(videoContentLoader.configContent.fromDate, toDate: videoContentLoader.configContent.toDate)
                $0.add(rule: RuleRequired(msg: ErrorMessages.spanError))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.cellSetup { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.titleLabel?.style(CurrentTheme.textStyleWith(cell.titleLabel.font.pointSize, weight: .regular))
                    cell.valueTextField?.style(CurrentTheme.textStyleWith(cell.valueTextField.font!.pointSize, weight: .regular))
                    cell.titleLabel?.textColor = CurrentTheme.standardColor
                    cell.valueTextField.attributedPlaceholder = NSAttributedString(string: "Select Span".localiz(), attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])
                }
                $0.displayValueFor = {
                    guard let val = $0 else { return nil }
                    return "1 " + val.rawValue
                }
                $0.onCellSelection { (cell, row) in
                    if row.value == nil {
                        row.value = row.options.first
                        row.updateCell()
                    }
                }
                $0.cellUpdate { (cell, row) in
                    cell.backgroundColor = CurrentTheme.cellBackgroundColor
                    cell.valueTextField?.textColor = CurrentTheme.titleColor
                    if !row.isValid {
                        
                        cell.valueTextField?.textColor = CurrentTheme.errorMessageColor
                        
                        var errors = ""
                        
                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }
                        
                        cell.valueTextField?.text = errors
                        cell.valueTextField?.isHidden = false
                    }
                }
                
            }
    }
    
    private func loadIndexPatters() {
        hud.show(animated: true)
        videoContentLoader.loadIndexPatters { [weak self] (res, error) in
            self?.hud.hide(animated: true)
            guard let options = res as? [IndexPattern] else { return }
            guard let indePatternRow = self?.form.rowBy(tag: FormTag.indexPattern) as? OAPickerInputRow<IndexPattern> else { return }
            indePatternRow.options = options
            indePatternRow.reload()
        }
    }
    
    private func loadVideoData() {
        hud.show(animated: true)
        videoContentLoader.loadVideoData { [weak self] (res, error) in
            guard let self = self else {
                return
            }
            self.hud.hide(animated: true)
            guard error == nil else {
                self.showAlert(error?.localizedDescription)
                return
            }
            
            if let result = res as? [VectorMapContainer], !result.isEmpty  {
                NavigationManager.shared.showVectorMapTimeline(self.navigationController!, data: result)

            } else if let result = res as? [VideoContent], !result.isEmpty {
                NavigationManager.shared.showBarchartRace(self.navigationController!, data: result, config: self.videoContentLoader.configContent)
            } else {
                self.showAlert("No data found!")
            }
        }
    }
    
    //MARK: Button Action
    @IBAction func generateVideoButtonAction(_ sender: UIButton) {
        let validationErrorList = form.validate()
        guard validationErrorList.count <= 0  else { return }
        
        let values = form.values()
        videoContentLoader.configContent.indexPattern       = values[FormTag.indexPattern] as? IndexPattern
        videoContentLoader.configContent.timeField          = values[FormTag.timeField] as? IPField
        videoContentLoader.configContent.field              = values[FormTag.field] as? IPField
        videoContentLoader.configContent.valueToDisplay     = values[FormTag.valueToDisplay] as? IPField
        videoContentLoader.configContent.fromDate           = values[FormTag.fromDate] as? Date ?? Date().dateAtStartOf(.day)
        videoContentLoader.configContent.toDate             = values[FormTag.toDate] as? Date ?? Date().dateAtEndOf(.day)
        videoContentLoader.configContent.videoType          = values[FormTag.videoType] as? VideoType ?? .barChartRace
        videoContentLoader.configContent.topMaxNumber       = Int(values[FormTag.maxCount] as? Double ?? 5.0)
        videoContentLoader.configContent.spanType           = values[FormTag.span] as? SpanType
        
        // Load Video Data with specified params
        loadVideoData()
    }
}

extension VideoConfigureViewController {
    struct FormTag {
        static let videoType        =   "VideoType"
        static let indexPattern     =   "IndexPattern"
        static let timeField        =   "TimeField"
        static let field            =   "Field"
        static let valueToDisplay   =   "ValueToDisplay"
        static let fromDate         =   "FromDate"
        static let toDate           =   "ToDate"
        static let maxCount         =   "MaxCount"
        static let span             =   "Span"
    }
    
    struct ErrorMessages {
        static let indexPatternError    =   "Please select Index Pattern".localiz()
        static let timeFieldError       =   "Please select Time Field".localiz()
        static let fieldError           =   "Please select Field".localiz()
        static let valueToDisplayError  =   "Please select Value To Display".localiz()
        static let spanError            =   "Please select Span".localiz()
    }
}
