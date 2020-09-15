//
//  OAPickerInputRow.swift
//  SampleForm
//
//  Created by Rameez on 02/07/2020.
//  Copyright © 2020 Rameez. All rights reserved.
//

import Eureka

open class _OAPickerInputCell<T> : Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate where T: Equatable {

    var titleLabel: UILabel!
    var valueTextField: UITextField!
    var infoButton: UIButton!

    lazy public var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    fileprivate var pickerInputRow: _OAPickerInputRow<T>? { return row as? _OAPickerInputRow<T> }

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLabels()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType = .none
        picker.delegate = self
        picker.dataSource = self
        
        infoButton?.isHidden = pickerInputRow?.shouldHideInfoButton ?? false
    }
    
    private func setupLabels() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        valueTextField = UITextField()
        valueTextField.isEnabled = false
        contentView.addSubview(valueTextField)
        
        let infoButtonSize: CGFloat = 20.0
        infoButton = UIButton(type: .custom)
        infoButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        infoButton.addTarget(self, action: #selector(_OAPickerInputCell.infoButtonAction(_:)), for: .touchUpInside)
        infoButton.setImage(UIImage(named: "info"), for: .normal)
        infoButton.imageView?.contentMode = .scaleAspectFit
        infoButton.layer.cornerRadius = infoButtonSize / 2.0
        contentView.addSubview(infoButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()
        let views: [String: UIView] = ["titleLabel": titleLabel!, "valueTextField": valueTextField!, "infoButton": infoButton, "holderView": self.contentView]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[titleLabel]-5-[infoButton(20)]-20-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[valueTextField]-5-[infoButton]-20-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel]-5-[valueTextField]-10-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=10)-[infoButton(20)]-(>=10)-|", options: [.alignAllCenterX], metrics: nil, views: views)
        contentView.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
        infoButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }

    @objc func infoButtonAction(_ sender: UIButton) {
        self.pickerInputRow?.infoButtonAction?(self as! OAPickerInputCell<T>, sender)
    }

    deinit {
        picker.delegate = nil
        picker.dataSource = nil
    }

    open override func update() {
        selectionStyle = row.isDisabled ? .none : .default

        titleLabel.text = row.title
        valueTextField.text = row.displayValueFor?(row.value) ?? (row as? NoValueDisplayTextConformance)?.noValueDisplayText

        if row.isHighlighted {
            textLabel?.textColor = tintColor
        }

        picker.reloadAllComponents()
    }

    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }

    open override var inputView: UIView? {
        return picker
    }

    open override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder
    }

    override open var canBecomeFirstResponder: Bool {
        return !row.isDisabled
    }

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerInputRow?.options.count ?? 0
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerInputRow?.displayValueFor?(pickerInputRow?.options[row])
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow rowNumber: Int, inComponent component: Int) {
        if let picker = pickerInputRow, picker.options.count > rowNumber {
            picker.value = picker.options[rowNumber]
            update()
        }
    }
}

open class OAPickerInputCell<T>: _OAPickerInputCell<T> where T: Equatable {

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        if let selectedValue = pickerInputRow?.value, let index = pickerInputRow?.options.firstIndex(of: selectedValue) {
            picker.selectRow(index, inComponent: 0, animated: true)
        }
    }

}


// MARK: OAPickerInputRow

open class _OAPickerInputRow<T> : Row<OAPickerInputCell<T>>, NoValueDisplayTextConformance where T: Equatable {
    open var noValueDisplayText: String? = nil

    open var options = [T]()

    open var infoButtonAction: ((Cell, UIButton) -> Void)?
    open var shouldHideInfoButton: Bool = false

    required public init(tag: String?) {
        super.init(tag: tag)

    }
}

/// A generic row where the user can pick an option from a picker view displayed in the keyboard area
public final class OAPickerInputRow<T>: _OAPickerInputRow<T>, RowType where T: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
