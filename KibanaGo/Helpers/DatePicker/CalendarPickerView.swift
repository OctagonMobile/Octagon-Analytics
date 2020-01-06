//
//  CalendarPickerView.swift
//  DemoLargeRangeDatePicker
//
//  Created by Rameez on 7/1/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SwiftDate

class CalendarPickerView: UIView {

    typealias DismissPickerBlock = (_ sender: Any) -> Void

    enum CalendarViewMode: String {
        case month                  =   "month"
        case day                    =   "day"
    }
    
    var calendarPickerTheme: CalendarDatePickerTheme    =   CalendarDatePickerTheme() {
        didSet {
            configureTheme()
        }
    }

    var dayLabelFont: UIFont                        =   UIFont.systemFont(ofSize: 17)
    var weekNameLabelFont: UIFont                   =   UIFont.systemFont(ofSize: 13.0, weight: .bold)

    var textColorNormal: UIColor                    =   .white
    var textColorSelected: UIColor                  =   .darkGray
    var validDateSelectionColor: UIColor            =   .white
    var centerDateColor: UIColor                    =   .lightGray
    var errorMessageColor: UIColor                  =   .orange
    
    var clearButtonTitleColor: UIColor              =   .white
    var clearButtonBackgroundColor: UIColor         =   .lightGray
    
    var applyButtonTitleColor: UIColor              =   .darkGray
    var applyButtonBackgroundColor: UIColor         =   .white
    
    var noSelectionErrorMessage: String             =   "Please select From and To date"
    var invalidDateSelectionError: String           =   "To date should be later than from date"

    var selectedDateDisplayFormat: String           =   "dd/MM/yyyy"
    var headerDateFormatString: String              =   "MMMM yyyy"

    /// Start Date for calendar. (Default: 20 years ago from current date)
    var startDate: Date                         = Calendar.current.date(byAdding: .year, value: -100, to: Date(), wrappingComponents: false) ?? Date() {
        didSet {
            setupCalendars()
        }
    }
    
    /// End Date for calendar. (Default: 20 years ahead from current date)
    var endDate: Date                           = Calendar.current.date(byAdding: .year, value: 100, to: Date(), wrappingComponents: false) ?? Date() {
        didSet {
            setupCalendars()
        }
    }

    var fromDate: Date?
    
    var toDate: Date?
    
    var currentMode: CalendarViewMode               =   .month
    
    var dateSelectionBlock: DateSelectionBlock?

    var dismissPickerBlock: DismissPickerBlock?
    
    //MARK: Outlets
    @IBOutlet weak var fromTitleLabel: UILabel?
    @IBOutlet weak var fromPrevButton: UIButton?
    @IBOutlet weak var fromNextButton: UIButton?
    @IBOutlet weak var fromCenterButton: UIButton?
    @IBOutlet weak var fromCalendarView: JTACMonthView?
    
    @IBOutlet weak var toTitleLabel: UILabel?
    @IBOutlet weak var toPrevButton: UIButton?
    @IBOutlet weak var toNextButton: UIButton?
    @IBOutlet weak var toCenterButton: UIButton?
    @IBOutlet weak var toCalendarView: JTACMonthView?

    @IBOutlet weak var fromMonthView: UICollectionView?
    @IBOutlet weak var toMonthView: UICollectionView?
    
    @IBOutlet weak var selectedDateLabel: UILabel?
    @IBOutlet weak var applyButton: UIButton?
    @IBOutlet weak var clearButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?
    
    /// Height of the Calendar Header
    private var calendarHeaderHeight: CGFloat                   = 30.0
    private var fromCalendarMode: CalendarViewMode              =   .month
    private var toCalendarMode: CalendarViewMode                =   .month

    private var monthList: [String] =  Calendar.current.shortMonthSymbols
    private var numberOfMonthPerRow: Int                        =   3
    
    //MARK: Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTheme()
    }
    
    func setup() {

        updateFromCalendar()
        updateToCalendar()

        setupMonthViews()
        didSwitchCalendarMode()
        fromMonthView?.reloadData()
        toMonthView?.reloadData()
    }
    
    
    private func updateFromCalendar() {
        let fromDate = self.fromDate ?? Date()
        fromCalendarView?.scrollToDate(fromDate)
        fromCalendarView?.visibleDates { [weak self] (dateSegment) in
            
            guard let strongSelf = self else { return }
            let format = self?.fromCalendarMode == .day ? strongSelf.headerDateFormatString : "yyyy"
            let centerTitle = self?.firstVisibleDateOf(self?.fromCalendarView)?.toFormat(format) ?? ""
            self?.fromCenterButton?.setTitle(centerTitle, for: .normal)
        }
        
    }
    
    private func updateToCalendar() {
        let toDate = self.toDate ?? Date()
        toCalendarView?.scrollToDate(toDate)
        toCalendarView?.visibleDates { [weak self] (dateSegment) in
            guard let strongSelf = self else { return }
            let format = self?.toCalendarMode == .day ? strongSelf.headerDateFormatString : "yyyy"
            let centerTitle = self?.firstVisibleDateOf(self?.toCalendarView)?.toFormat(format) ?? ""
            self?.toCenterButton?.setTitle(centerTitle, for: .normal)
        }
    }
    
    func reLayoutCalendarPicker() {
        fromMonthView?.performBatchUpdates({
            (fromMonthView?.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
            updateFromCalendar()
        }, completion: nil)
        
        toMonthView?.performBatchUpdates({
            (toMonthView?.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
            updateToCalendar()
        }, completion: nil)
    }

    private func setupCalendars() {
        setupCalendar(fromCalendarView)
        setupCalendar(toCalendarView)
    }
    
    private func configureTheme() {
        
        dayLabelFont = calendarPickerTheme.dayLabelFont
        weekNameLabelFont = calendarPickerTheme.weekNameLabelFont
        textColorNormal = calendarPickerTheme.textColorNormal
        textColorSelected = calendarPickerTheme.textColorSelected
        validDateSelectionColor = calendarPickerTheme.validDateSelectionColor
        centerDateColor = calendarPickerTheme.centerDateColor
        errorMessageColor = calendarPickerTheme.errorMessageColor
        clearButtonTitleColor = calendarPickerTheme.clearButtonTitleColor
        clearButtonBackgroundColor = calendarPickerTheme.clearButtonBackgroundColor
        applyButtonTitleColor = calendarPickerTheme.applyButtonTitleColor
        applyButtonBackgroundColor = calendarPickerTheme.applyButtonBackgroundColor
        noSelectionErrorMessage = calendarPickerTheme.noSelectionErrorMessage
        invalidDateSelectionError = calendarPickerTheme.invalidDateSelectionError
        selectedDateDisplayFormat = calendarPickerTheme.selectedDateDisplayFormat
        headerDateFormatString = calendarPickerTheme.headerDateFormatString
        fromCenterButton?.titleLabel?.font = calendarPickerTheme.titleLabelFont
        toCenterButton?.titleLabel?.font = calendarPickerTheme.titleLabelFont
        fromTitleLabel?.font = calendarPickerTheme.titleLabelFont
        toTitleLabel?.font = calendarPickerTheme.titleLabelFont
        initialSetup()
    }
    
    private func initialSetup() {
        applyButton?.backgroundColor = applyButtonBackgroundColor
        applyButton?.setTitleColor(applyButtonTitleColor, for: .normal)
        applyButton?.setTitleColor(applyButtonTitleColor.withAlphaComponent(0.3), for: .disabled)
        applyButton?.layer.cornerRadius = 5.0
        applyButton?.titleLabel?.font = calendarPickerTheme.actionButtonFont
        
        clearButton?.backgroundColor = clearButtonBackgroundColor
        clearButton?.setTitleColor(clearButtonTitleColor, for: .normal)
        clearButton?.setTitleColor(clearButtonTitleColor.withAlphaComponent(0.3), for: .disabled)
        clearButton?.layer.cornerRadius = 5.0
        clearButton?.titleLabel?.font = calendarPickerTheme.actionButtonFont

        cancelButton?.backgroundColor = clearButtonBackgroundColor
        cancelButton?.setTitleColor(clearButtonTitleColor, for: .normal)
        cancelButton?.layer.cornerRadius = 5.0
        cancelButton?.titleLabel?.font = calendarPickerTheme.actionButtonFont

        fromCenterButton?.layer.cornerRadius = 5.0
        toCenterButton?.layer.cornerRadius = 5.0
        didSwitchCalendarMode()
        applyButton?.isEnabled = didSelectValidDates()
        clearButton?.isEnabled = didSelectDates()

        let leftImage = UIImage(named: calendarPickerTheme.leftArrowImageName)
        let rightImage = UIImage(named: calendarPickerTheme.rightArrowImageName)
        fromPrevButton?.setImage(leftImage, for: .normal)
        fromNextButton?.setImage(rightImage, for: .normal)
        toPrevButton?.setImage(leftImage, for: .normal)
        toNextButton?.setImage(rightImage, for: .normal)
    }
    
    private func setupCalendar(_ calendar: JTACMonthView?) {
        calendar?.semanticContentAttribute = .forceLeftToRight
        calendar?.isScrollEnabled = false
        calendar?.scrollingMode = .stopAtEachSection
        calendar?.allowsRangedSelection = true
        calendar?.allowsMultipleSelection = false
        calendar?.minimumLineSpacing = 1.0
        calendar?.minimumInteritemSpacing = 1.0
        
        calendar?.register(UINib(nibName: NibNames.datePickerCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifier.datePickerCollectionViewCellId)

        calendar?.register(UINib(nibName: NibNames.datePickerCollectionReusableView, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.datePickerCollectionReusableView)
        
        calendar?.calendarDelegate = self
        calendar?.calendarDataSource = self
    }
    
    private func didSwitchCalendarMode() {
        
        fromCalendarView?.isHidden = fromCalendarMode == .month
        fromMonthView?.isHidden = fromCalendarMode != .month
        toCalendarView?.isHidden = toCalendarMode == .month
        toMonthView?.isHidden = toCalendarMode != .month
        
        fromCenterButton?.backgroundColor = fromCalendarMode == .day ? clearButtonBackgroundColor : .clear
        toCenterButton?.backgroundColor = toCalendarMode == .day ? clearButtonBackgroundColor : .clear
    }
    
    private func setupMonthViews() {
        fromMonthView?.delegate = self
        fromMonthView?.dataSource = self
        fromMonthView?.register(UINib(nibName: NibNames.datePickerCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifier.datePickerCollectionViewCellId)
        (fromMonthView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical

        toMonthView?.delegate = self
        toMonthView?.dataSource = self
        toMonthView?.register(UINib(nibName: NibNames.datePickerCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifier.datePickerCollectionViewCellId)
        (toMonthView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
    }
    
    fileprivate func firstVisibleDateOf(_ calendar: JTACMonthView?) -> Date? {
        
        var firstDate: Date? = nil
        calendar?.visibleDates { (dateSegment) in
            if let firstVisibleCalendarDate = dateSegment.monthDates.first?.date {
                firstDate = firstVisibleCalendarDate
            }
        }
        return firstDate
    }
    
    private func didSelectValidDates() -> Bool {
        
        guard let fromDate = fromDate, let toDate = toDate else { return false }

        return fromDate < toDate
    }
    
    private func didSelectDates() -> Bool {
        guard let _ = fromDate, let _ = toDate else { return false }
        return true
    }
    
    private func showSelectedDate() {
        applyButton?.isEnabled = didSelectValidDates()
        clearButton?.isEnabled = didSelectDates()
        applyButton?.backgroundColor = applyButton?.isEnabled == true ? applyButtonBackgroundColor : applyButtonBackgroundColor.withAlphaComponent(0.3)
        clearButton?.backgroundColor = clearButton?.isEnabled == true ? clearButtonBackgroundColor : clearButtonBackgroundColor.withAlphaComponent(0.3)
        selectedDateLabel?.textColor = didSelectValidDates() ? textColorNormal : errorMessageColor

        guard let fromDate = fromDate, let toDate = toDate else {
            selectedDateLabel?.text = noSelectionErrorMessage.localiz()
            return
        }
        
        if didSelectValidDates() {
            selectedDateLabel?.text = "Selected:".localiz() + " \(fromDate.toFormat(selectedDateDisplayFormat)) - \(toDate.toFormat(selectedDateDisplayFormat))"
        } else {
            selectedDateLabel?.text = invalidDateSelectionError.localiz()
        }
        
    }
    
    //MARK: Actions
    @IBAction func fromPrevButtonAction(_ sender: UIButton) {
        
        if fromCalendarMode == .day {
            fromCalendarView?.scrollToSegment(.previous)
        } else {
            // Month View
            if let firstVisibleDate = firstVisibleDateOf(fromCalendarView) {
                var dateComponents: DateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: firstVisibleDate)
                dateComponents.year = (firstVisibleDate.year - 1)
                let selectedDate: Date? = Calendar.current.date(from: dateComponents)
                fromCalendarView?.scrollToDate(selectedDate ?? Date())
            }
        }
    }
    
    @IBAction func fromNextButtonAction(_ sender: UIButton) {
        
        if fromCalendarMode == .day {
            // Day View
            fromCalendarView?.scrollToSegment(.next)
        } else {
            // Month View
            
            guard let firstVisibleDateFromCalendar = firstVisibleDateOf(fromCalendarView) else  { return }
            
            var dateComponents: DateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: firstVisibleDateFromCalendar)
            dateComponents.year = (firstVisibleDateFromCalendar.year + 1)
            let selectedDate: Date? = Calendar.current.date(from: dateComponents)
            fromCalendarView?.scrollToDate(selectedDate ?? Date())
        }
    }
    
    @IBAction func fromCenterButtonAction(_ sender: UIButton) {
        fromCalendarMode = .month
        didSwitchCalendarMode()
        
        let format = fromCalendarMode == .day ? headerDateFormatString : "yyyy"
        let centerTitle = firstVisibleDateOf(fromCalendarView)?.toFormat(format) ?? ""
        fromCenterButton?.setTitle(centerTitle, for: .normal)

    }
    
    @IBAction func toPrevButtonAction(_ sender: UIButton) {
        
        if toCalendarMode == .day {
            toCalendarView?.scrollToSegment(.previous)
        } else {
            
            guard let firstVisibleDateToCalendar = firstVisibleDateOf(toCalendarView) else { return }
            
            var dateComponents: DateComponents = Calendar.current.dateComponents([.year, .day, .hour, .minute, .second], from: firstVisibleDateToCalendar)
            dateComponents.year = (firstVisibleDateToCalendar.year - 1)
            let selectedDate: Date? = Calendar.current.date(from: dateComponents)
            toCalendarView?.scrollToDate(selectedDate ?? Date())
        }
    }
    
    @IBAction func toNextButtonAction(_ sender: UIButton) {
        
        if toCalendarMode == .day {
            toCalendarView?.scrollToSegment(.next)
        } else {
            guard let firstVisibleDate = firstVisibleDateOf(toCalendarView) else { return }
            
            var dateComponents: DateComponents = Calendar.current.dateComponents([.year, .day, .hour, .minute, .second], from: firstVisibleDate)
            dateComponents.year = (firstVisibleDate.year + 1)
            let selectedDate: Date? = Calendar.current.date(from: dateComponents)
            toCalendarView?.scrollToDate(selectedDate ?? Date())
        }
    }
    
    @IBAction func toCenterButtonAction(_ sender: UIButton) {
        toCalendarMode = .month
        didSwitchCalendarMode()
        
        let format = toCalendarMode == .day ? headerDateFormatString : "yyyy"
        let centerTitle = firstVisibleDateOf(toCalendarView)?.toFormat(format) ?? ""
        toCenterButton?.setTitle(centerTitle, for: .normal)

    }
    
    @IBAction func clearButtonAction(_ sender: UIButton) {
        fromDate = nil
        toDate = nil
        fromCalendarView?.deselectAllDates(triggerSelectionDelegate: false)
        toCalendarView?.deselectAllDates(triggerSelectionDelegate: false)
        
        fromCalendarView?.reloadData()
        toCalendarView?.reloadData()
        showSelectedDate()
    }
    
    @IBAction func applyButtonAction(_ sender: UIButton) {
        
        showSelectedDate()
        
        guard didSelectValidDates() else { return }
            
        dateSelectionBlock?(self, DatePickerMode.calendarPicker, fromDate, toDate, "")
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        dismissPickerBlock?(self)
    }
}

extension CalendarPickerView: JTACMonthViewDelegate, JTACMonthViewDataSource {
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
       
        handleCellSelected(calendar, view: cell, cellState: cellState)
        handleCellTextColor(calendar, view: cell, cellState: cellState)
        
        let fontSize = selectedDateLabel?.font.pointSize ?? 15.0
        selectedDateLabel?.font = calendarPickerTheme.actionButtonFont.withSize(fontSize)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CellIdentifier.datePickerCollectionViewCellId, for: indexPath) as? DatePickerCollectionViewCell else {
            return JTACDayCell()
        }
        cell.dayLabel?.font = dayLabelFont
        cell.dayLabel?.text = cellState.text
        cell.isHidden = cellState.dateBelongsTo != .thisMonth
        
        handleCellSelected(calendar, view: cell, cellState: cellState)
        handleCellTextColor(calendar, view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        
        if calendar == fromCalendarView {
            fromDate = date.dateAt(.startOfDay)
        } else {
            toDate = date.dateAt(.endOfDay)
        }

        if let selectedFromDate = fromDate {
            fromCalendarView?.selectDates([selectedFromDate], triggerSelectionDelegate: false)
        }
        
        if let selectedToDate = toDate {
            toCalendarView?.selectDates([selectedToDate], triggerSelectionDelegate: false)
        }
        
        showSelectedDate()

        fromCalendarView?.reloadData()
        toCalendarView?.reloadData()
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        if calendar == fromCalendarView {
            let format = fromCalendarMode == .day ? headerDateFormatString : "yyyy"
            let centerTitle = firstVisibleDateOf(fromCalendarView)?.toFormat(format) ?? ""
            fromCenterButton?.setTitle(centerTitle, for: .normal)
        } else {
            
            let format = toCalendarMode == .day ? headerDateFormatString : "yyyy"
            let centerTitle = firstVisibleDateOf(toCalendarView)?.toFormat(format) ?? ""
            toCenterButton?.setTitle(centerTitle, for: .normal)
        }
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        guard let header = calendar.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CellIdentifier.datePickerCollectionReusableView, for: indexPath) as? DatePickerCollectionReusableView else {
            return JTACMonthReusableView()
        }
        
        header.titleFont = weekNameLabelFont
        header.titleColor = textColorNormal
        header.updateUI()
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: calendarHeaderHeight)
    }
    
    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return cellState.dateBelongsTo == .thisMonth
    }
    
    func calendar(_ calendar: JTACMonthView, shouldDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        return cellState.dateBelongsTo == .thisMonth
    }
}

extension CalendarPickerView {
    
    fileprivate func handleCellTextColor(_ calendar: JTACMonthView?, view: JTACDayCell?, cellState: CellState) {
        guard let validCell = view as? DatePickerCollectionViewCell else { return }
        
        let shouldShowSelectedView = (calendar == fromCalendarView && fromDate == cellState.date.dateAt(.startOfDay)) || (calendar == toCalendarView && toDate == cellState.date.dateAt(.endOfDay))

        if shouldShowSelectedView {
            validCell.dayLabel?.textColor = textColorSelected
        } else {
            validCell.dayLabel?.textColor = textColorNormal

        }
    }
    
    fileprivate func handleCellSelected(_ calendar: JTACMonthView?, view: JTACDayCell?, cellState: CellState) {
        guard let validCell = view as? DatePickerCollectionViewCell else { return }

        let shouldShowSelectedView = (calendar == fromCalendarView && fromDate == cellState.date.dateAt(.startOfDay)) || (calendar == toCalendarView && toDate == cellState.date.dateAt(.endOfDay))

        if shouldShowSelectedView {
            validCell.selectedView?.isHidden = false
            let color = didSelectValidDates() ? validDateSelectionColor : errorMessageColor
            validCell.selectedView?.backgroundColor = color
        } else {
            validCell.selectedView?.isHidden = true
            validCell.backgroundColor = UIColor.clear
        }
        
        let isCurrentDate = cellState.date.compare(toDate: Date(), granularity: Calendar.Component.day) == ComparisonResult.orderedSame
        validCell.currentDateView?.layer.borderWidth = isCurrentDate ? 1.0 : 0.0
    }

}

extension CalendarPickerView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.datePickerCollectionViewCellId, for: indexPath) as? DatePickerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.selectedView?.isHidden = true
        cell.dayLabel?.font = dayLabelFont
        cell.dayLabel?.text = monthList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let firstVisibleDate = collectionView == fromMonthView ? firstVisibleDateOf(fromCalendarView) : firstVisibleDateOf(toCalendarView) else {
            return
        }
        var dateComponents: DateComponents = Calendar.current.dateComponents([.year, .day, .hour, .minute, .second], from: firstVisibleDate)
        dateComponents.month = (indexPath.row + 1)
        let selectedDate: Date? = Calendar.current.date(from: dateComponents)
        
        if collectionView == fromMonthView {
            fromCalendarView?.scrollToDate(selectedDate ?? Date())
            fromCalendarMode = .day
        } else {
            toCalendarView?.scrollToDate(selectedDate ?? Date())
            toCalendarMode = .day
        }
        
        didSwitchCalendarMode()
    }
}

extension CalendarPickerView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfColumns = monthList.count / numberOfMonthPerRow
        let minimumInteritemSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0.0
        let minimumLineSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0.0

        let width = (collectionView.frame.width - (minimumInteritemSpacing * CGFloat(numberOfMonthPerRow - 1))) / CGFloat(numberOfMonthPerRow)
        let height = (collectionView.frame.height - (minimumLineSpacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)

        guard width > 0 && height > 0 else {
            return CGSize.zero
        }
        return CGSize(width: width, height: height)
        
    }
}

extension CalendarPickerView {
    struct CellIdentifier {
        static let datePickerCollectionViewCellId   =   "DatePickerCollectionViewCell"
        static let datePickerCollectionReusableView =   "DatePickerCollectionReusableView"
    }
    
    struct NibNames {
        static let datePickerCollectionViewCell   =   "DatePickerCollectionViewCell"
        static let datePickerCollectionReusableView = "DatePickerCollectionReusableView"
    }
}
