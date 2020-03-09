//
//  UIViewControllerExtension.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/30/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import PopupDialog

typealias OkActionBlock = () -> Void

extension UIViewController {
    
    func showAlert(_ title: String? = nil ,_ message: String? = "") {
        
        showOkCancelAlert(title, message, okActionBlock: nil)
    }
    
    func showOkCancelAlert(_ title: String? = nil ,_ message: String? = "", okTitle: String = OK, okActionBlock: OkActionBlock?, cancelTitle: String? = nil, cancelActionBlock: OkActionBlock? = nil) {
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: nil)
        popup.view.backgroundColor = CurrentTheme.cellBackgroundColor
        // Create buttons
        let okButton = DefaultButton(title: okTitle) {
            DLog("Clicked 'OK'")
            okActionBlock?()
        }
        okButton.titleColor = CurrentTheme.standardColor
        popup.addButton(okButton)

        if let cancelTitle = cancelTitle {
            let cancelButton = CancelButton(title: cancelTitle) {
                DLog("Cancelled")
                cancelActionBlock?()
            }
            cancelButton.titleColor = CurrentTheme.titleColor
            popup.addButton(cancelButton)
        }

        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
}
