//
//  TutorialLoginCarouselView.swift
//  KibanaGo
//
//  Created by Rameez on 2/11/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class TutorialLoginCarouselView: UIView {
    
    var showAutoFill: Bool  =   true {
        didSet {
            fillButton?.isHidden = !showAutoFill
            arrowLeftImageView?.isHidden = !showAutoFill
            centerAlignmentIPadConstraint?.constant = showAutoFill ? 200 : 0
        }
    }
    var tutorialAutoFillActionBlock: TutorialButtonActionBlock?

    @IBOutlet weak var tutorialCredentialsImageView: UIImageView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var centerAlignmentIPadConstraint: NSLayoutConstraint?
    @IBOutlet weak var arrowLeftImageView: UIImageView?
    @IBOutlet var fillButton: UIButton!
    
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let autoFillTitle = NSAttributedString(string: "Auto Fill".localiz(), attributes:
            [.foregroundColor: CurrentTheme.tutorialButtonColor,
             .underlineColor: CurrentTheme.tutorialButtonColor,
             .underlineStyle: NSUnderlineStyle.single.rawValue])
        fillButton.setAttributedTitle(autoFillTitle, for: .normal)
        pageNumberLabel.backgroundColor = CurrentTheme.tutorialHighlightedButtonColor
        
        let arrowImageName = "TutorialArrowLeft-" + CurrentTheme.rawValue
        arrowLeftImageView?.image = UIImage(named: arrowImageName)
        
        var credentialsImageName = "TutorialCredentials"
        credentialsImageName += (isIPhone ? "iPhone" : "iPad")
        credentialsImageName += CurrentTheme.isDarkTheme ? "-Dark" : "-Light"
        tutorialCredentialsImageView.image = UIImage(named: credentialsImageName)
    }
    
    //MARK: Button Actions
    @IBAction func autoFillButtonAction(_ sender: UIButton) {
        tutorialAutoFillActionBlock?(sender)
    }
}
