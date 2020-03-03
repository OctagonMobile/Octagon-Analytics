//
//  TutorialSettingsCarouselView.swift
//  KibanaGo
//
//  Created by Rameez on 2/13/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class TutorialSettingsCarouselView: UIView {
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        pageNumberLabel.backgroundColor = CurrentTheme.tutorialHighlightedButtonColor
    }
}
