//
//  QuickDatePickerView.swift
//  DemoLargeRangeDatePicker
//
//  Created by Rameez on 7/1/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import SwiftDate

enum QuickPicker: String {
    
    case today                  =   "Today"
    case yesterday              =   "Yesterday"
    case lastThirtyDays         =   "Last 30 days"
    case lastSixtyDays          =   "Last 60 days"
    case lastNintyDays          =   "Last 90 days"
    case lastSixMonths          =   "Last 6 months"
    case lastOneYear            =   "Last 1 year"
    case lastTwoYear            =   "Last 2 years"
    case lastFiveYear           =   "Last 5 years"
    
    func selectedDate() -> (fromDate: Date, toDate: Date) {
        var fromDate = Date()
        var toDate = Date()
        
        var finalDate:(Date, Date)
        
        switch self {
        case .today:
            fromDate = fromDate.dateAt(.startOfDay)
            toDate = toDate.dateAt(.endOfDay)
        case .yesterday:
            fromDate = (fromDate - 1.days).dateAt(.startOfDay)
            toDate = (toDate - 1.days).dateAt(.endOfDay)
        case .lastThirtyDays:
            fromDate = fromDate - 30.days
        case .lastSixtyDays:
            fromDate = fromDate - 60.days
        case .lastNintyDays:
            fromDate = fromDate - 90.days
        case .lastSixMonths:
            fromDate = fromDate - 6.months
        case .lastOneYear:
            fromDate = fromDate - 1.years
        case .lastTwoYear:
            fromDate = fromDate - 2.years
        default:
            fromDate = fromDate - 5.years
        }
        
        finalDate = (fromDate,toDate)
        return finalDate
    }
    
    var localizedValue: String {
        return self.rawValue.localiz()
    }
    
    static var count: Int { return QuickPicker.quickPickerValues.count }
    static var quickPickerValues: [[QuickPicker]] {
        if isIPhone {
            return [[today, yesterday, lastThirtyDays, lastSixtyDays, lastNintyDays, lastSixMonths, lastOneYear, lastTwoYear, lastFiveYear]]
        }
        return [[today, yesterday, lastThirtyDays, lastSixtyDays, lastNintyDays], [lastSixMonths, lastOneYear, lastTwoYear, lastFiveYear]]
    }
}

typealias EnableCustomizeBlock = (_ sender: Any,_ isEnabled: Bool) -> Void
typealias QuickPickerSelectionBlock = (_ sender: Any,_ mode: DatePickerMode, _ selectedValue: QuickPicker?) -> Void

class QuickDatePickerView: UIView {

    var quickPickerSelectionBlock: QuickPickerSelectionBlock?
    var enableCustomizeBlock: EnableCustomizeBlock?

    var selectedValue: QuickPicker?
    
    var shouldShowCustomizeOption: Bool         = true
    var customizeEnabled: Bool                  = false
    
    var customizedButtonTitle: String           =   "Customized"
    var cellBackgroundColorNormal: UIColor      =   .lightGray
    var cellBackgroundColorSelected: UIColor    =   .gray
    var cellBackgroundColorHighlighted: UIColor =   .darkGray
    var customizedButtonEnabledTitleColor: UIColor   =   .darkGray
    var customizedButtonEnabledColor: UIColor   =   .white
    var titleColorNormal: UIColor               =   .white

    var font: UIFont                            =   UIFont.systemFont(ofSize: 12.0)
    var cellHeight: CGFloat    =   35
    private let extraOffsetWidth: CGFloat   =   25
    @IBOutlet weak var quickPickerCollectionView: UICollectionView?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        quickPickerCollectionView?.register(UINib(nibName: NibNames.quickDatePickerCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifier.quickDatePickerCollectionViewCell)
        quickPickerCollectionView?.dataSource = self
        quickPickerCollectionView?.delegate = self
        (quickPickerCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 0.0
        (quickPickerCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 8.0
        quickPickerCollectionView?.backgroundColor = .clear
        quickPickerCollectionView?.isScrollEnabled = isIPhone
        (quickPickerCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = isIPhone ? .horizontal : .vertical
        quickPickerCollectionView?.indicatorStyle = .white
        
        if isIPhone {
            quickPickerCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        }
    }
    
    func flashScrollIndicator() {
        quickPickerCollectionView?.flashScrollIndicators()
    }
    
    func reLayoutQuickPicker() {
        quickPickerCollectionView?.performBatchUpdates({
            (quickPickerCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
        }, completion: nil)
    }
    
    func reset(_ value: QuickPicker? = nil) {
        self.selectedValue = value
        quickPickerCollectionView?.reloadData()
    }
    
    fileprivate func isCustomizedButtonIndex(_ indexPath: IndexPath) -> Bool {
        let list = QuickPicker.quickPickerValues[indexPath.section]
        
        let isLastSection = indexPath.section == QuickPicker.quickPickerValues.count - 1
        let isLastItem = indexPath.row == list.count
        return (isLastSection && isLastItem)
    }
}

extension QuickDatePickerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return QuickPicker.quickPickerValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section != QuickPicker.quickPickerValues.count - 1 else {
            // +1 for Customized button
            let count = QuickPicker.quickPickerValues[section].count
            return shouldShowCustomizeOption ? count + 1 : count
        }
        return QuickPicker.quickPickerValues[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.quickDatePickerCollectionViewCell, for: indexPath) as? QuickDatePickerCollectionViewCell else { return UICollectionViewCell() }
        
        guard !isCustomizedButtonIndex(indexPath) else {
            cell.titleLabel?.text = customizedButtonTitle
            cell.cellBackgroundColor = customizeEnabled ? customizedButtonEnabledColor : cellBackgroundColorNormal
            cell.titleLabel?.textColor = customizeEnabled ? customizedButtonEnabledTitleColor : titleColorNormal
            cell.titleLabel?.font = font
            return cell
        }
        
        let value =  (QuickPicker.quickPickerValues[indexPath.section])[indexPath.row]
        cell.titleLabel?.text = value.localizedValue
        cell.titleLabel?.textColor = titleColorNormal
        cell.titleLabel?.font = font
        cell.cellBackgroundColor = value == selectedValue ? cellBackgroundColorSelected : cellBackgroundColorNormal
        cell.highlightedColor = cellBackgroundColorHighlighted
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard !isCustomizedButtonIndex(indexPath) else {
            customizeEnabled = !customizeEnabled
            enableCustomizeBlock?(self, customizeEnabled)
            collectionView.reloadData()
            return
        }

        selectedValue =  (QuickPicker.quickPickerValues[indexPath.section])[indexPath.row]
        
        if let selectedValue = selectedValue {
            quickPickerSelectionBlock?(self, .quickPicker, selectedValue)
        }

        collectionView.reloadData()
    }
}

extension QuickDatePickerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var text = ""
        if isCustomizedButtonIndex(indexPath) {
            text = customizedButtonTitle
        } else {
            let item = QuickPicker.quickPickerValues[indexPath.section][indexPath.row]
            text = item.rawValue
        }
        
        let width = text.getWidth(withConstraintedHeight: cellHeight, font: font)
        return CGSize(width: width + extraOffsetWidth , height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard !isIPhone else {
            return UIEdgeInsets.zero
        }
        
        let interItemSpacing = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0.0

        //(disabled because JTCalendar pod has refresh issue)
        let numberOfCells = CGFloat(QuickPicker.quickPickerValues[section].count)
//        if section == QuickPicker.quickPickerValues.count - 1 {
//            numberOfCells += 1
//        }
        
        let totalWidth = totalCellWidthForItemsAt(section)
//        let edgeInsets = (collectionView.frame.size.width - ((numberOfCells - 1) * interItemSpacing)  - totalWidth) / 2

        let edgeInsets = (collectionView.frame.size.width - (numberOfCells * interItemSpacing)  - totalWidth) / 2

        return UIEdgeInsets(top: 8, left: edgeInsets, bottom: 0, right: edgeInsets)

    }

    private func totalCellWidthForItemsAt(_ section: Int) -> CGFloat {
        let itemsList = QuickPicker.quickPickerValues[section]
        var totalWidth: CGFloat = 0
        for item in itemsList {
            let width = item.rawValue.getWidth(withConstraintedHeight: cellHeight, font: font)
            totalWidth += (width + extraOffsetWidth)
        }
        //(disabled because JTCalendar pod has refresh issue)
//        if section == QuickPicker.quickPickerValues.count - 1 {
//            let width = customizedButtonTitle.getWidth(withConstraintedHeight: cellHeight, font: font)
//            totalWidth += (width + extraOffsetWidth)
//        }
        return totalWidth
    }
}

extension QuickDatePickerView {
    struct CellIdentifier {
        static let quickDatePickerCollectionViewCell = "QuickDatePickerCollectionViewCell"
    }
    
    struct NibNames {
        static let quickDatePickerCollectionViewCell = "QuickDatePickerCollectionViewCell"
    }
}

extension String {
    func getWidth(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
