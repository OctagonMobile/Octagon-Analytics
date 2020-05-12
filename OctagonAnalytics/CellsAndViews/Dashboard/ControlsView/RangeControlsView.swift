//
//  RangeControlsView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 5/10/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import TTRangeSlider

class RangeControlsView: UIView {
    
    var rangeControlWidget: RangeControlsWidget? {
        didSet { updateContent() }
    }
    
    var rangeSelectionUpdateBlock: ControlsRangeSelectionBlock?

    typealias ControlsRangeSelectionBlock = (_ control: ControlsWidgetBase?,_ min: Float,_ max: Float) -> Void

    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var maxValueTextField: UITextField!
    @IBOutlet weak var minValueTextField: UITextField!
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = CurrentTheme.titleColor
        
        //Setup Range Slider
        rangeSlider.delegate = self
        rangeSlider.handleType = .rectangle
        rangeSlider.handleSize = CGSize(width: 25.0, height: 25.0)
        rangeSlider.lineHeight = 4.0
        rangeSlider.selectedHandleDiameterMultiplier = 1.1
        rangeSlider.tintColor = CurrentTheme.sliderLineColor
        rangeSlider.tintColorBetweenHandles = CurrentTheme.standardColor
        rangeSlider.handleColor = CurrentTheme.standardColor
        rangeSlider.handleBorderWidth = 2.0
        rangeSlider.handleBorderColor = CurrentTheme.cellBackgroundColor
        rangeSlider.hideLabels = true

        //Setup TextFields
        minValueTextField.delegate = self
        maxValueTextField.delegate = self

        func configureTextField(_ textField: UITextField) {
            textField.textColor = CurrentTheme.titleColor
            textField.layer.borderWidth = CurrentTheme.isDarkTheme ? 0.0 : 2.0
            textField.layer.cornerRadius = 5.0
            textField.layer.borderColor = CurrentTheme.textFieldBorderColor.cgColor
            textField.layer.borderColor = CurrentTheme.textFieldBorderColor.cgColor
            textField.tintColor = CurrentTheme.titleColor
        }
        
        configureTextField(minValueTextField)
        configureTextField(maxValueTextField)
    }
    
    func updateContent() {
        titleLabel?.text = rangeControlWidget?.control.fieldName

        rangeSlider.minValue = rangeControlWidget?.minValue ?? 0
        rangeSlider.maxValue = rangeControlWidget?.maxValue ?? 0
        
        rangeSlider.enableStep = true
        rangeSlider.step = Float(rangeControlWidget?.control.rangeOptions?.step ?? 1)
        
        if let rangeCtr = rangeControlWidget {
            minValueTextField.text = rangeCtr.selectedMinValue == nil ? "" : "\(Int(rangeCtr.selectedMinValue ?? 0.0))"
            maxValueTextField.text = rangeCtr.selectedMaxValue == nil ? "" : "\(Int(rangeCtr.selectedMaxValue ?? 0.0))"
        }
        
        rangeSlider?.selectedMinimum = rangeControlWidget?.selectedMinValue ?? rangeSlider.minValue
        rangeSlider?.selectedMaximum = rangeControlWidget?.selectedMaxValue ?? rangeSlider.minValue
    }

    
    private func updateSliderValue() {
        let min = (minValueTextField.text as NSString?)?.floatValue ?? rangeSlider.selectedMinimum
        let max = (maxValueTextField.text as NSString?)?.floatValue ?? rangeSlider.selectedMaximum
        
        rangeSlider.selectedMinimum = min > max ? max : min
        rangeSlider.selectedMaximum = max < min ? min : max
        
        minValueTextField.text = "\(Int(rangeSlider.selectedMinimum))"
        maxValueTextField.text = "\(Int(rangeSlider.selectedMaximum))"
        
        rangeControlWidget?.selectedMinValue = rangeSlider.selectedMinimum
        rangeControlWidget?.selectedMaxValue = rangeSlider.selectedMaximum

        rangeSelectionUpdateBlock?(rangeControlWidget, rangeSlider.selectedMinimum, rangeSlider.selectedMaximum)
    }

}

extension RangeControlsView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (string == string.filter("0123456789.".contains))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSliderValue()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateSliderValue()
        textField.resignFirstResponder()
        return true
    }
}

extension RangeControlsView: TTRangeSliderDelegate {
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        minValueTextField.text = "\(Int(selectedMinimum))"
        maxValueTextField.text = "\(Int(selectedMaximum))"
    }
    
    func didEndTouches(in sender: TTRangeSlider!) {
        rangeControlWidget?.selectedMinValue = sender.selectedMinimum
        rangeControlWidget?.selectedMaxValue = sender.selectedMaximum
        rangeSelectionUpdateBlock?(rangeControlWidget, sender.selectedMinimum, sender.selectedMaximum)
    }
}
