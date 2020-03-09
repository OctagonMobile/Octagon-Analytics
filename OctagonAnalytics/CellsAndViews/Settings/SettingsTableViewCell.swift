//
//  SettingsTableViewCell.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/19/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var holderView: UIView!
    @IBOutlet var valueLabel: UILabel?
    
    internal var settingsItem: SettingsItem?
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        holderView.style(.roundCorner(5.0, 2.0, CurrentTheme.cellBackgroundColor))
        holderView.backgroundColor = CurrentTheme.cellBackgroundColor

    }
    
    func updateUI() {
        titleLabel.style(CurrentTheme.textStyleWith(titleLabel.font.pointSize, weight: .regular))
        valueLabel?.style(CurrentTheme.textStyleWith(valueLabel?.font.pointSize ?? 12.0, weight: .regular))
    }

    func setup(_ setting: SettingsItem) {
        settingsItem = setting
        titleLabel.text = setting.name.localiz()
    }

}


class TouchIdTableViewCell: SettingsTableViewCell {
    
    typealias SwitchActionBlock = (_ sender: Any, _ settingsItem: SettingsItem?) -> Void
    
    var isTouchIdEnabled: Bool  =   false {
        didSet {
            touchIdSwitch.isOn = isTouchIdEnabled
        }
    }
    var switchAction: SwitchActionBlock?
    @IBOutlet var touchIdSwitch: UISwitch!

    override func setup(_ setting: SettingsItem) {
        super.setup(setting)
        titleLabel.text = TouchIdHelper.shared.isFaceIDSupported ? setting.secondaryName : setting.name
    }
    //MARK: button Action
    @IBAction func switchAction(_ sender: UISwitch) {
        switchAction?(sender, settingsItem)
    }
    

}
