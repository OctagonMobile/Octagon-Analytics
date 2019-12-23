//
//  LanguageTableViewCell.swift
//  KibanaGo
//
//  Created by Rameez on 9/29/19.
//  Copyright © 2019 MyCompany. All rights reserved.
//

import UIKit
import LanguageManager_iOS

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var holderView: UIView?
    @IBOutlet var selectedMarkView: UIImageView?
    @IBOutlet weak var iconImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        holderView?.style(.roundCorner(5.0, 2.0, CurrentTheme.cellBackgroundColor))
        holderView?.backgroundColor = CurrentTheme.cellBackgroundColor
        
        let imageName = CurrentTheme.isDarkTheme ? "Checkbox-Selected-Dark" : "Checkbox-Selected"
        selectedMarkView?.image = UIImage(named: imageName)
    }

    func updateUI(_ language: Language) {
        
        titleLabel?.text = language.desc
        titleLabel?.style(CurrentTheme.textStyleWith(titleLabel?.font.pointSize ?? 12.0, weight: .regular))
        selectedMarkView?.isHidden = LanguageManager.shared.currentLanguage.rawValue != language.code
        iconImageView?.image = UIImage(named: language.iconName)
    }
}
