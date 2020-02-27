//
//  RangeControlsCollectionViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit
import TTRangeSlider


class RangeControlsCollectionViewCell: ControlsBaseCollectionViewCell {
        
    var rangeControl: RangeControlsWidget? {
        return controlWidget as? RangeControlsWidget
    }
    
    //MARK: Outlets
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var maxValueTextField: UITextField!
    @IBOutlet weak var minValueTextField: UITextField!

    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        minValueTextField.delegate = self
        maxValueTextField.delegate = self
                
        minValueTextField.textColor = CurrentTheme.titleColor
        maxValueTextField.textColor = CurrentTheme.titleColor
        minValueTextField.layer.borderWidth = CurrentTheme.isDarkTheme ? 0.0 : 2.0
        maxValueTextField.layer.borderWidth = CurrentTheme.isDarkTheme ? 0.0 : 2.0
        minValueTextField.layer.cornerRadius = 5.0
        maxValueTextField.layer.cornerRadius = 5.0
        minValueTextField.layer.borderColor = CurrentTheme.textFieldBorderColor.cgColor
        maxValueTextField.layer.borderColor = CurrentTheme.textFieldBorderColor.cgColor
        minValueTextField.backgroundColor = CurrentTheme.headerViewBackgroundColorSecondary
        maxValueTextField.backgroundColor = CurrentTheme.headerViewBackgroundColorSecondary
        minValueTextField.tintColor = CurrentTheme.titleColor
        maxValueTextField.tintColor = CurrentTheme.titleColor

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
    }
    
    override func updateCellContent() {
        super.updateCellContent()
        rangeSlider.enableStep = true
        rangeSlider.step = Float(controlWidget?.control.rangeOptions?.step ?? 1)
        
        if let rangeCtr = rangeControl {
            minValueTextField.text = rangeCtr.selectedMinValue == nil ? "" : "\(Int(rangeCtr.selectedMinValue ?? 0.0))"
            maxValueTextField.text = rangeCtr.selectedMaxValue == nil ? "" : "\(Int(rangeCtr.selectedMaxValue ?? 0.0))"
        }
        
        rangeSlider?.selectedMinimum = rangeControl?.selectedMinValue ?? 0.0
        rangeSlider?.selectedMaximum = rangeControl?.selectedMaxValue ?? 0.0
    }
    
    private func updateSliderValue() {
        let min = (minValueTextField.text as NSString?)?.floatValue ?? rangeSlider.selectedMinimum
        let max = (maxValueTextField.text as NSString?)?.floatValue ?? rangeSlider.selectedMaximum
        
        rangeSlider.selectedMinimum = min > max ? max : min
        rangeSlider.selectedMaximum = max < min ? min : max
        
        minValueTextField.text = "\(Int(rangeSlider.selectedMinimum))"
        maxValueTextField.text = "\(Int(rangeSlider.selectedMaximum))"
        
        rangeControl?.selectedMinValue = rangeSlider.selectedMinimum
        rangeControl?.selectedMaxValue = rangeSlider.selectedMaximum
    }
    
}

extension RangeControlsCollectionViewCell: UITextFieldDelegate {
    
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


extension RangeControlsCollectionViewCell: TTRangeSliderDelegate {
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        minValueTextField.text = "\(Int(selectedMinimum))"
        maxValueTextField.text = "\(Int(selectedMaximum))"
    }
    
    func didEndTouches(in sender: TTRangeSlider!) {
        rangeControl?.selectedMinValue = sender.selectedMinimum
        rangeControl?.selectedMaxValue = sender.selectedMaximum
    }
}
