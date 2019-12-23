//
//  MultiDatePickerViewController.swift
//  DemoLargeRangeDatePicker
//
//  Created by Rameez on 7/1/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit
import SwiftDate

enum DatePickerMode: String {
    case quickPicker            =   "QuickPicker"
    case calendarPicker         =   "CalendarPicker"
}

struct QuickDatePickerTheme {
    var backgroundColorNormal: UIColor       =   .lightGray
    var backgroundColorSelected: UIColor     =   .gray
    var backgroundColorHighlighted: UIColor  =   .darkGray
    
    var font: UIFont                            =       UIFont.systemFont(ofSize: 12.0)
    var cellHeight: CGFloat                     =       35.0
}

struct CalendarDatePickerTheme {
    
    var dayLabelFont: UIFont                        =   UIFont.systemFont(ofSize: 17)
    var weekNameLabelFont: UIFont                   =   UIFont.systemFont(ofSize: 13.0, weight: .bold)
    
    var textColorNormal: UIColor                    =   .white
    var textColorSelected: UIColor                  =   .darkGray
    var validDateSelectionColor: UIColor            =   .white
    var centerDateColor: UIColor                    =   .lightGray
    var errorMessageColor: UIColor                  =   .orange
    
    var actionButtonFont: UIFont                    =   UIFont.systemFont(ofSize: 15)
    var titleLabelFont: UIFont                      =   UIFont.systemFont(ofSize: 17, weight: .bold)

    var clearButtonTitleColor: UIColor              =   .white
    var clearButtonBackgroundColor: UIColor         =   .lightGray

    var applyButtonTitleColor: UIColor              =   .darkGray
    var applyButtonBackgroundColor: UIColor         =   .white
    
    var noSelectionErrorMessage: String             =   "SelectDatesError"
    var invalidDateSelectionError: String           =   "DateValidationError"
    
    var selectedDateDisplayFormat: String           =   "dd/MM/yyyy"
    var headerDateFormatString: String              =   "MMMM yyyy"
    
    var leftArrowImageName: String                  =   "LeftArrowDateRange"
    var rightArrowImageName: String                 =   "RightArrowDateRange"
}

typealias DateSelectionBlock = (_ sender: Any,_ mode: DatePickerMode, _ from: Date?, _ toDate: Date?,_ selectedDateString: String) -> Void

class MultiDatePickerViewController: UIViewController {

    /// Date selection callback.
    var dateSelectionBlock: DateSelectionBlock?

    /// Current date picker mode.
    var currentPickerMode: DatePickerMode   =   .quickPicker

    var quickPickerTheme: QuickDatePickerTheme    =   QuickDatePickerTheme()
    
    var calendarPickerTheme: CalendarDatePickerTheme    =   CalendarDatePickerTheme()

    //MARK: Calendar Picker
    /// Start Date for calendar. (Default: 20 years ago from current date)
    var startDate: Date                         = Calendar.current.date(byAdding: .year, value: -20, to: Date(), wrappingComponents: false) ?? Date()
    
    /// End Date for calendar. (Default: 20 years ahead from current date)
    var endDate: Date                           = Calendar.current.date(byAdding: .year, value: 20, to: Date(), wrappingComponents: false) ?? Date()

    /// Preselected from date. (Used only if DatePickerMode = calendarPicker )
    var selectedFromDate: Date?
    
    /// Preselected to date. (Used only if DatePickerMode = calendarPicker )
    var selectedToDate: Date?

    //MARK: Quick Picker
    /// Preselected Quick picker date. (Used only if DatePickerMode = quickPicker )
    var preSelectedQuickPickerDate: QuickPicker?

    
    //MARK: Private
    /**
     Containes currently selected date string based on the picker mode.
     eg.: if picker mode = .calendarPicker then "Last 5 years"
     if picker mode = .quickPicker then "then "June 06 2018 - June 08 2018""
     */
    private var selectedDateString: String?

    /// Returns 'True' if the Calendar is shown.
    private var isCustomPickerEnabled: Bool          =   false

    /// Size of the date picker view.
    private var pickerSize: CGSize {
        let height: CGFloat = isCustomPickerEnabled ? 520.0 : 130.0
        return CGSize(width: 660, height: height)
    }

    //MARK: Outlets
    @IBOutlet weak var quickPickerView: QuickDatePickerView?
    @IBOutlet weak var calendarPickerView: CalendarPickerView?
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialConfiguration()
        setupQuickPicker()
        setupCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isIPhone {
            quickPickerView?.flashScrollIndicator()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            
            guard isIPhone else { return }
            self.quickPickerView?.reLayoutQuickPicker()
            self.calendarPickerView?.reLayoutCalendarPicker()
            
        }
        
    }

    override public var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .regular), UITraitCollection(verticalSizeClass: .regular)])
        }
        return super.traitCollection
    }

    //MARK: Private Functions
    /**
     Initial Configurations. (Colors/Fonts/Initial-values etc.)
     */
    private func initialConfiguration() {
        if isIPhone { quickPickerView?.semanticContentAttribute = .forceLeftToRight }
        SwiftDate.defaultRegion = Region.local
        view.backgroundColor = isIPhone ? CurrentTheme.darkBackgroundColor : .clear
        isCustomPickerEnabled = true //isIPhone || (currentPickerMode == .calendarPicker) (disabled because JTCalendar pod has refresh issue)
        presentingViewController?.presentedViewController?.preferredContentSize = pickerSize
    }
    
    /**
     Initial Setup for Quick Picker View
     */
    private func setupQuickPicker() {
        quickPickerView?.shouldShowCustomizeOption = false //!isIPhone (disabled because JTCalendar pod has refresh issue)
        quickPickerView?.cellBackgroundColorNormal = quickPickerTheme.backgroundColorNormal
        quickPickerView?.cellBackgroundColorSelected = quickPickerTheme.backgroundColorSelected
        quickPickerView?.cellBackgroundColorHighlighted = quickPickerTheme.backgroundColorHighlighted
        quickPickerView?.font = quickPickerTheme.font
        quickPickerView?.cellHeight = quickPickerTheme.cellHeight
        quickPickerView?.customizeEnabled = isCustomPickerEnabled
        quickPickerView?.selectedValue = preSelectedQuickPickerDate

        quickPickerView?.quickPickerSelectionBlock = { [weak self] (sender, mode, selectedValue) in

            self?.currentPickerMode = mode
            self?.preSelectedQuickPickerDate = selectedValue
            self?.selectedDateString = selectedValue?.rawValue
            self?.applyAndDismiss()
        }

        quickPickerView?.enableCustomizeBlock = { [weak self] (sender, isEnabled) in

            guard let strongSelf = self else { return }
            self?.isCustomPickerEnabled = isEnabled
            self?.calendarPickerView?.isHidden = !isEnabled
            
            self?.presentingViewController?.presentedViewController?.preferredContentSize = strongSelf.pickerSize
            self?.setupCalendar()
        }
    }

    /**
     Initial Setup for Calendar
     */
    private func setupCalendar() {
        
        calendarPickerView?.isHidden = !isCustomPickerEnabled
        calendarPickerView?.calendarPickerTheme = calendarPickerTheme
        calendarPickerView?.startDate = startDate
        calendarPickerView?.endDate = endDate

        calendarPickerView?.dateSelectionBlock = { [weak self] (sender, mode, fromDate, toDate, dateString) in
            self?.selectedFromDate = fromDate
            self?.selectedToDate = toDate
            self?.currentPickerMode = mode
            self?.applyAndDismiss()
        }
        
        calendarPickerView?.dismissPickerBlock = { [weak self] sender in
            self?.dismiss(animated: true, completion: nil)
        }
        
        if isCustomPickerEnabled {
            calendarPickerView?.setup()
        }
    }

    
    /**
     Returns 'True' if the selection made in date picker is valid
     */
    private func didSelectValidDateRange() -> Bool {
        return (currentPickerMode == .calendarPicker && selectedFromDate != nil && selectedToDate != nil) ||
            (currentPickerMode == .quickPicker  && quickPickerView?.selectedValue != nil )
    }
    
    /**
     Apply the selection and dismiss the picker
     */
    private func applyAndDismiss() {
        
        guard didSelectValidDateRange() else {
            return
        }
        
        dismiss(animated: true) {
            if self.currentPickerMode == .calendarPicker, let selectedFromDate = self.selectedFromDate, let selectedToDate = self.selectedToDate {
                let fromDateString = selectedFromDate.toFormat("MMMM dd yyyy")
                let toDateString = selectedToDate.toFormat("MMMM dd yyyy")
                let finalDateString = self.currentPickerMode == .calendarPicker ? (fromDateString + " - " + toDateString) : self.selectedDateString
                self.dateSelectionBlock?(self, self.currentPickerMode, selectedFromDate, selectedToDate, finalDateString ?? "")

            } else if self.currentPickerMode == .quickPicker, let selectedValue = self.quickPickerView?.selectedValue {
                self.dateSelectionBlock?(self, self.currentPickerMode, selectedValue.selectedDate().fromDate, selectedValue.selectedDate().toDate, self.selectedDateString ?? "")
            }
        }
    }

}
