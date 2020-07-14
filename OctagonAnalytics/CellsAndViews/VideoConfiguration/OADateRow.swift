//
//  OADateRow.swift
//  OctagonAnalytics
//
//  Created by Rameez on 05/07/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Eureka

final class OADateRow: Row<OADateCell>, RowType, NoValueDisplayTextConformance, DatePickerRowProtocol {
    
    /// The minimum value for this row's UIDatePicker
    public var minimumDate: Date?

    /// The maximum value for this row's UIDatePicker
    public var maximumDate: Date?

    /// The interval between options for this row's UIDatePicker
    public var minuteInterval: Int?

    public var noValueDisplayText: String? = nil
    public var dateFormatter: DateFormatter?

    required init(tag: String?) {
        super.init(tag: tag)

        dateFormatter = DateFormatter()
        dateFormatter?.timeStyle = .none
        dateFormatter?.dateStyle = .medium
        dateFormatter?.locale = Locale.current
        
        displayValueFor = { [unowned self] value in
            guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.string(from: val)
        }
    }
}

class OADateCell: DateCell {
    var titleLabel: UILabel!
    var valueTextField: UITextField!

    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func setup() {
        datePicker.datePickerMode = datePickerMode()
        datePicker.addTarget(self, action: #selector(OADateCell.datePickerValueChangedd(_:)), for: .valueChanged)
    }

    private func datePickerMode() -> UIDatePicker.Mode {
        switch row {
        case is DateRow:
            return .date
        case is TimeRow:
            return .time
        case is DateTimeRow:
            return .dateAndTime
        case is CountDownRow:
            return .countDownTimer
        default:
            return .date
        }
    }

    private func setupLabels() {

        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        valueTextField = UITextField()
        valueTextField.isEnabled = false
        contentView.addSubview(valueTextField)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()
        let views: [String: UIView] = ["titleLabel": titleLabel!, "valueTextField": valueTextField!, "holderView": self.contentView]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLabel]-20-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[valueTextField]-20-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel]-5-[valueTextField]-10-|", options: [], metrics: nil, views: views)
        contentView.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
    }
    
    override func update() {
        
        datePicker.setDate(row.value ?? Date(), animated: row is CountDownPickerRow)
        datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
        datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
        if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval {
            datePicker.minuteInterval = minuteIntervalValue
        }

        titleLabel.text = row.title
        valueTextField.text = row.displayValueFor?(row.value) ?? (row as? NoValueDisplayTextConformance)?.noValueDisplayText

        if row.isHighlighted {
            textLabel?.textColor = tintColor
        }

    }

    @objc func datePickerValueChangedd(_ sender: UIDatePicker) {
        row.value = sender.date
        valueTextField.text = row.displayValueFor?(row.value)
    }

}
