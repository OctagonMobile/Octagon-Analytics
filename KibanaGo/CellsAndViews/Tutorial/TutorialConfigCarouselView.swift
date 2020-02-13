//
//  TutorialConfigCarouselView.swift
//  KibanaGo
//
//  Created by Rameez on 2/11/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import UIKit

class TutorialConfigCarouselView: UIView {

    @IBOutlet var copyToClipboardButton: UIButton!
    @IBOutlet var kibanaPluginUrlLabel: UILabel?
    //MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let copyToClipboardTitle = NSAttributedString(string: "Copy to Clipboard".localiz(), attributes:
            [.foregroundColor: UIColor.systemBlue,
             .underlineColor: UIColor.systemBlue,
             .underlineStyle: NSUnderlineStyle.single.rawValue])
        copyToClipboardButton?.setAttributedTitle(copyToClipboardTitle, for: .normal)
        
        kibanaPluginUrlLabel?.text = "https://github.com/OctagonMobile/Kibana-Go-Plugin"
    }

    
    //MARK: Button Actions
    @IBAction func copyToClipboardButtonAction(_ sender: UIButton) {
        UIPasteboard.general.string = kibanaPluginUrlLabel?.text
    }
    
}
