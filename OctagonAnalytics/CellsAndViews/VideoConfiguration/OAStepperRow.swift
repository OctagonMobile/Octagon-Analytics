//
//  OAStepperRow.swift
//  OctagonAnalytics
//
//  Created by Rameez on 15/09/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Eureka

open class OAStepperCell: StepperCell {
    
    @IBOutlet weak var infoButton: UIButton?
    
    //MARK: Functions
    open override func setup() {
        super.setup()
        infoButton?.isHidden = (row as? _OAStepperRow)?.shouldHideInfoButton ?? false
    }
    
    open override func update() {
        super.update()
        textLabel?.text = nil
    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        (row as? _OAStepperRow)?.infoButtonAction?(self, sender)
    }
}

open class _OAStepperRow: Row<OAStepperCell> {
    
    open var infoButtonAction: ((Cell, UIButton) -> Void)?
    open var shouldHideInfoButton: Bool = false

    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { value in
                                guard let value = value else { return nil }
                                return DecimalFormatter().string(from: NSNumber(value: value)) }
    }
}

/// Double row that has a UIStepper as accessoryType
public final class OAStepperRow: _OAStepperRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<OAStepperCell>(nibName: "OAStepperCell")
    }
}
