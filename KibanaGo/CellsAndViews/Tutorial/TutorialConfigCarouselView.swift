//
//  TutorialConfigCarouselView.swift
//  KibanaGo
//
//  Created by Rameez on 2/11/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class TutorialConfigCarouselView: UIView {

    var tutorialConfigActionBlock: TutorialButtonActionBlock?

    //MARK: Button Actions
    @IBAction func infoButtonAction(_ sender: UIButton) {
        tutorialConfigActionBlock?(sender)
    }
    
}
