//
//  VideoConfigureViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 09/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import Eureka
import MBProgressHUD

class VideoConfigureViewController: FormViewController {

    var videoContentLoader  =   VideoContentLoader()
    
    @IBOutlet weak var generateVideoButton: UIButton!
    
    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()

    private var filteredFields:[IPField]    =   []
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = CurrentTheme.lightBackgroundColor
        title   =   "Video Configuration".localiz()
        navigationItem.leftBarButtonItems = []
        
        generateVideoButton.style(CurrentTheme.textStyleWith(generateVideoButton.titleLabel?.font.pointSize ?? 20, weight: .regular, color: CurrentTheme.secondaryTitleColor))
        generateVideoButton.backgroundColor = CurrentTheme.standardColor

        createForm()
        loadIndexPatters()
    }
    
    private func createForm() {
        form +++ Section("")
            <<< PickerInlineRow<IndexPattern>() {
                $0.title = "Index Pattern"
                $0.tag = FormTag.indexPattern
                $0.add(rule: RuleRequired(msg: "Please select Index Pattern."))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.options = videoContentLoader.indexPattersList
                $0.displayValueFor = {
                    guard let indexPattern = $0 else { return nil }
                    return indexPattern.title
                }
                $0.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = CurrentTheme.standardColor
                    
                    if !row.isValid {
                        
                        cell.textLabel?.textColor = .red
                        
                        var errors = ""
                        
                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }
                        
                        cell.detailTextLabel?.text = errors
                        cell.detailTextLabel?.isHidden = false
                        cell.detailTextLabel?.textAlignment = .left
                    }
                    
                }
                $0.onChange { (row) in
                    
                    guard let timeFieldRow = self.form.rowBy(tag: FormTag.timeField) as? PickerInlineRow<IPField>,
                        let fieldRow = self.form.rowBy(tag: FormTag.preselectField) as? MultipleSelectorRow<IPField>,
                        let selectedIndexPattern = row.value else { return }
                    
                    self.filteredFields = selectedIndexPattern.fields.filter({ $0.type == "number"})
                    self.filteredFields = self.filteredFields.filter({ $0.name != "_score"})
                    
                    timeFieldRow.options = selectedIndexPattern.fields.filter({ $0.type == "date"})
                    timeFieldRow.value = nil
                    timeFieldRow.updateCell()
                    
                    fieldRow.options = self.filteredFields.compactMap({ $0 })
                    fieldRow.value = Set(self.filteredFields.prefix(5))
                    fieldRow.updateCell()
                    
                }
            }
            
            <<< PickerInlineRow<IPField>() {
                $0.title = "Time Field"
                $0.tag = FormTag.timeField
                $0.options = []
                $0.add(rule: RuleRequired(msg: "Please select Time Field."))
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.hidden = Condition.function([FormTag.indexPattern]){ form in
                    if let row = form.rowBy(tag: FormTag.indexPattern) as? PickerInlineRow<IndexPattern> {
                        return row.value == nil
                    }
                    return false
                }
                $0.displayValueFor = {
                    guard let field = $0 else { return nil }
                    return field.name
                }
                $0.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = CurrentTheme.standardColor
                    if !row.isValid {
                        
                        cell.textLabel?.textColor = .red
                        
                        var errors = ""
                        
                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }
                        
                        cell.detailTextLabel?.text = errors
                        cell.detailTextLabel?.isHidden = false
                        cell.detailTextLabel?.textAlignment = .left
                    }
                }
                $0.onChange { (row) in
                    
                    guard let fieldRow = self.form.rowBy(tag: FormTag.preselectField) as? MultipleSelectorRow<IPField> else { return }
                    self.filteredFields = self.filteredFields.filter({ $0.name != row.value?.name })
                    fieldRow.options = self.filteredFields.compactMap({ $0 })
                    fieldRow.value = nil
                    fieldRow.updateCell()
                }
            }
            
            <<< MultipleSelectorRow<IPField>() {
                $0.title = "Fields to display"
                $0.tag = FormTag.preselectField
                $0.hidden = Condition.function([FormTag.timeField]){ form in
                    if let row = form.rowBy(tag: FormTag.timeField) as? PickerInlineRow<IPField> {
                        return row.value == nil
                    }
                    return false
                }
                $0.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = CurrentTheme.standardColor
                    if !row.isValid {
                        
                        cell.textLabel?.textColor = .red
                        
                        var errors = ""
                        
                        for error in row.validationErrors {
                            let errorString = error.msg + "\n"
                            errors = errors + errorString
                        }
                        
                        cell.detailTextLabel?.text = errors
                        cell.detailTextLabel?.isHidden = false
                        cell.detailTextLabel?.textAlignment = .left
                    }
                }
                $0.displayValueFor  = {
                    if let t = $0 {
                        return t.compactMap({ $0.name }).joined(separator: ", ")
                    }
                    return nil
                }
                $0.onPresent { (from, to) in
                    to.selectableRowCellSetup = { cell, row in
                        row.displayValueFor = { val in
                            if let value = val {
                                return value.name
                            }
                            return nil
                        }
                    }
                }
            }
            
            <<< DateInlineRow() {
                $0.title = "From Date"
                $0.tag = FormTag.fromDate
                $0.value = Date()
                $0.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = CurrentTheme.standardColor
                    if let toDateRow = self.form.rowBy(tag: FormTag.toDate) as? DateInlineRow {
                        toDateRow.minimumDate = row.value
                    }
                }
            }
            
            <<< DateInlineRow() {
                $0.title = "To Date"
                $0.tag = FormTag.toDate
                $0.value = Date()
                $0.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = CurrentTheme.standardColor
                    if let fromDateRow = self.form.rowBy(tag: FormTag.fromDate) as? DateInlineRow {
                        fromDateRow.maximumDate = row.value
                    }
                }
            }
    }
    
    private func loadIndexPatters() {
        hud.show(animated: true)
        videoContentLoader.loadIndexPatters { [weak self] (res, error) in
            self?.hud.hide(animated: true)
            guard let options = res as? [IndexPattern] else { return }
            guard let indePatternRow = self?.form.rowBy(tag: FormTag.indexPattern) as? PickerInlineRow<IndexPattern> else { return }
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
            
            guard let result = res as? [VideoContent], !result.isEmpty else {
                self.showAlert("No data found!")
                return
            }
            
            NavigationManager.shared.showBarchartRace(self.navigationController!, data: result)
        }
    }
    
    //MARK: Button Action
    @IBAction func generateVideoButtonAction(_ sender: UIButton) {
        let validationErrorList = form.validate()
        guard validationErrorList.count <= 0  else { return }
        
        let values = form.values()
        videoContentLoader.configContent.indexPattern       = values[FormTag.indexPattern] as? IndexPattern
        videoContentLoader.configContent.timeField          = values[FormTag.timeField] as? IPField
        videoContentLoader.configContent.fromDate           = values[FormTag.fromDate] as? Date
        videoContentLoader.configContent.toDate             = values[FormTag.toDate] as? Date
        
        videoContentLoader.configContent.selectedFieldList.removeAll()
        let selectedFields = values[FormTag.preselectField] as? Set<IPField> ?? []
        for field in selectedFields {
            guard let found = filteredFields.filter({ $0.name == field.name}).first else { return }
            videoContentLoader.configContent.selectedFieldList.append(found)
        }
        
        // Load Video Data with specified params
        loadVideoData()
    }
}

extension VideoConfigureViewController {
    struct FormTag {
        static let indexPattern     =   "IndexPattern"
        static let timeField        =   "TimeField"
        static let preselectField   =   "PreselectField"
        static let fromDate         =   "FromDate"
        static let toDate           =   "ToDate"
    }
}
