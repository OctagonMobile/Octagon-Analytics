//
//  BaseViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import LanguageManager_iOS

class BaseViewController: UIViewController {

    fileprivate var label: UILabel = UILabel(frame: CGRect.zero)

    var backButtonIconName: String {
        return LanguageManager.shared.isRightToLeft ? "backFlip" : "back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = CurrentTheme.lightBackgroundColor
        
        setupBarButtons()
    }
    
    fileprivate func setupBarButtons() {
        navigationItem.rightBarButtonItems = rightBarButtons()
        navigationItem.leftBarButtonItems = leftBarButtons()
    }
    
    func rightBarButtons() -> [UIBarButtonItem] {
        if keyCloakEnabled || SettingsBundleHelper.isLoginEnabled() {
            return [UIBarButtonItem(image: UIImage(named: "Profile"), style: .plain, target: self, action: #selector(rightBarButtonAction(_ :)))]
        } else {
//            let languageTitle = LanguageManager.shared.currentLanguage == .en ? "العربية" : "Eng"
//            return [UIBarButtonItem(title: languageTitle, style: .plain, target: self, action: #selector(switchLanguage(_ :)))]
            
            let languageIcon = LanguageManager.shared.currentLanguage == .en ? "uae" : "uk"
            return [UIBarButtonItem(image: UIImage(named: languageIcon), style: .plain, target: self, action: #selector(switchLanguage(_ :)))]

        }
    }
    
    func leftBarButtons() -> [UIBarButtonItem] {
        return [UIBarButtonItem(image: UIImage(named: backButtonIconName), style: .plain, target: self, action: #selector(leftBarButtonAction(_ :)))]
    }
    
    @objc func leftBarButtonAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func rightBarButtonAction(_ sender: UIBarButtonItem) {
        showDropDownController(barButton: sender)
    }
    
    @objc func switchLanguage(_ sender: UIBarButtonItem) {
        let code = LanguageManager.shared.currentLanguage == .en ? "ar" : "en"
        NavigationManager.shared.resetAppLanguage(code)
    }

    //MARK:
    func showNoItemsAvailable(_ text: String = "No data available") {
        label.removeFromSuperview()
        label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.style(CurrentTheme.calloutTextStyle(CurrentTheme.futureDateTextColor))
        label.text = text
        view.addSubview(label)
        
        let centerX = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: label, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        
        let leading = NSLayoutConstraint(item: label, attribute: .leadingMargin, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: 10)
        let trailing = NSLayoutConstraint(item: label, attribute: .trailingMargin, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .trailingMargin, multiplier: 1, constant: 10)

        let top = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: 25)
        let bottom = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .bottom, multiplier: 1, constant: 25)

        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([centerX, centerY, leading, trailing, top, bottom])
        
    }
    
    func hideNoItemsAvailable() {
        label.removeFromSuperview()
    }

}

extension BaseViewController {
    func showDropDownController(barButton: UIBarButtonItem) {
        let popOverContent = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.dropDownPopOverViewController) as? DropDownPopOverViewController ?? DropDownPopOverViewController()

        popOverContent.didSelectDropDown = {[weak self] (selectedItem) in
            if selectedItem.identifier == "Logout" {
                self?.logout()
            } else if selectedItem.identifier == "Settings" {
                popOverContent.dismiss(animated: true, completion: {
                    NavigationManager.shared.showSettingsScreen()
                })
            }
        }
        
        popOverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = popOverContent.popoverPresentationController
        popOverContent.preferredContentSize = CGSize(width: 150, height: 50)
        popover?.permittedArrowDirections = .any
        popover?.barButtonItem = barButton
        popover?.delegate = self
        popover?.backgroundColor = CurrentTheme.cellBackgroundColorPair.last?.withAlphaComponent(1.0)
        present(popOverContent, animated: true, completion: nil)

    }
    
    private func logout() {
        
        NavigationManager.shared.showLoginScreen()
        Session.shared.appliedFilters.removeAll()
        
        if keyCloakEnabled {
            Session.shared.logoutKeycloak(nil)
        } else {
            Session.shared.logout(nil)
        }
    }
}

extension BaseViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension BaseViewController {
    struct ViewControllerIdentifiers {
        static let dropDownPopOverViewController = "DropDownPopOverViewController"
    }
}
