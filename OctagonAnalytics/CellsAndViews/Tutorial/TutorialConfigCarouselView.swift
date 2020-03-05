//
//  TutorialConfigCarouselView.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/11/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class TutorialConfigCarouselView: UIView {

    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet var copyToClipboardButton: UIButton!
    @IBOutlet var kibanaPluginUrlLabel: UILabel?
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let copyToClipboardTitle = NSAttributedString(string: "Copy to Clipboard".localiz(), attributes:
            [.foregroundColor: CurrentTheme.tutorialButtonColor,
             .underlineColor: CurrentTheme.tutorialButtonColor,
             .underlineStyle: NSUnderlineStyle.single.rawValue])
        copyToClipboardButton?.setAttributedTitle(copyToClipboardTitle, for: .normal)
        
        let copyToClipboardHighlightedTitle = NSAttributedString(string: "Copy to Clipboard".localiz(), attributes:
            [.foregroundColor: CurrentTheme.tutorialHighlightedButtonColor,
             .underlineColor: CurrentTheme.tutorialHighlightedButtonColor,
             .underlineStyle: NSUnderlineStyle.single.rawValue])
        copyToClipboardButton?.setAttributedTitle(copyToClipboardHighlightedTitle, for: .highlighted)

        pageNumberLabel.backgroundColor = CurrentTheme.tutorialHighlightedButtonColor
        kibanaPluginUrlLabel?.text = "https://octagonmobile.github.io/Octagon-Analytics-Plugin-Download/Octagon-Analytics-6.5.4.zip"
    }

    
    //MARK: Button Actions
    @IBAction func copyToClipboardButtonAction(_ sender: UIButton) {
        UIPasteboard.general.string = kibanaPluginUrlLabel?.text
    }
    
}
