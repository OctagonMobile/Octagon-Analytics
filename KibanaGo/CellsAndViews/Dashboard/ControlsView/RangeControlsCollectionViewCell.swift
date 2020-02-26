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
    
    typealias ControlsRangeSelectionBlock = (_ control: Control?,_ min: Float,_ max: Float) -> Void

    var rangeSelectionBlock: ControlsRangeSelectionBlock?
    
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
        minValueTextField.layer.borderWidth = 2.0
        maxValueTextField.layer.borderWidth = 2.0
        minValueTextField.layer.cornerRadius = 5.0
        maxValueTextField.layer.cornerRadius = 5.0
        minValueTextField.layer.borderColor = CurrentTheme.textFieldBorderColor.cgColor
        maxValueTextField.layer.borderColor = CurrentTheme.textFieldBorderColor.cgColor

        rangeSlider.delegate = self
        rangeSlider.handleType = .rectangle
        rangeSlider.handleSize = CGSize(width: 25.0, height: 25.0)
        rangeSlider.lineHeight = 4.0
        rangeSlider.selectedHandleDiameterMultiplier = 1.0
        rangeSlider.handleColor = CurrentTheme.standardColor
        rangeSlider.tintColorBetweenHandles = CurrentTheme.standardColor
        rangeSlider.handleBorderWidth = 2.0
        rangeSlider.handleBorderColor = CurrentTheme.secondaryTitleColor
    }
    
    override func updateCellContent() {
        super.updateCellContent()
        rangeSlider.enableStep = true
        rangeSlider.step = Float(control?.rangeOptions?.step ?? 1)
    }
    
    private func updateSliderValue() {
        let min = (minValueTextField.text as NSString?)?.floatValue ?? rangeSlider.selectedMinimum
        let max = (maxValueTextField.text as NSString?)?.floatValue ?? rangeSlider.selectedMaximum
        
        rangeSlider.selectedMinimum = min > max ? max : min
        rangeSlider.selectedMaximum = max < min ? min : max
    }
    
}

extension RangeControlsCollectionViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSliderValue()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}


extension RangeControlsCollectionViewCell: TTRangeSliderDelegate {
    func rangeSlider(_ sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        minValueTextField.text = "\(Int(selectedMinimum))"
        maxValueTextField.text = "\(Int(selectedMaximum))"
    }
    
    func didEndTouches(in sender: TTRangeSlider!) {
        rangeSelectionBlock?(control, sender.selectedMinimum, sender.selectedMaximum)
    }
}
