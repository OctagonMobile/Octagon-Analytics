//
//  AuthenticationViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/19/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import MBProgressHUD

class AuthenticationViewController: BaseViewController {

    typealias TouchIdConfigurationBlock = (_ sender: Any,_ success: Bool) -> Void

    var touchIdConfigurationBlock: TouchIdConfigurationBlock?
    var enableUserNameField: Bool   =   false
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var checkBoxButton: UIButton!
    @IBOutlet var userNameSeparator: UIView!
    @IBOutlet var passwordSeparator: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title   =   "Authentication".localiz()
        userNameTextField.isEnabled = enableUserNameField
        userNameTextField.text = Session.shared.user.userName
        continueButton.style(.roundCorner(5.0, 0.0, .clear))

        continueButton.isEnabled = (passwordTextField.text?.isEmpty == false)
        continueButton.backgroundColor = CurrentTheme.standardColor.withAlphaComponent(0.5)
        
        userNameSeparator.backgroundColor = CurrentTheme.separatorColorSecondary
        passwordSeparator.backgroundColor = CurrentTheme.separatorColorSecondary

        passwordTextField.addTarget(self, action: #selector(AuthenticationViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)


        userNameTextField.style(CurrentTheme.bodyTextStyle(CurrentTheme.titleColor))
        passwordTextField.style(CurrentTheme.bodyTextStyle(CurrentTheme.titleColor))

        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password".localiz(),
                                                                     attributes: [NSAttributedString.Key.foregroundColor: CurrentTheme.enabledStateBackgroundColor])

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let size = continueButton.titleLabel?.font.pointSize ?? 20
        continueButton.titleLabel?.style(CurrentTheme.textStyleWith(size, weight: .regular, color: CurrentTheme.secondaryTitleColor))
    }
    
    override func rightBarButtons() -> [UIBarButtonItem] {
        return []
    }
    
    override func leftBarButtonAction(_ sender: UIBarButtonItem) {
        super.leftBarButtonAction(sender)
        self.touchIdConfigurationBlock?(self, false)
    }
        
    @objc func textFieldDidChange(_ textField: UITextField) {
        continueButton.isEnabled = (textField.text?.isEmpty == false)
        continueButton.backgroundColor = continueButton.isEnabled ? CurrentTheme.standardColor : CurrentTheme.standardColor.withAlphaComponent(0.5)
    }
    
    private func verify() {
        
        let hud = MBProgressHUD.showAdded(to: self.view ?? UIView(), animated: true)
        hud.animationType = .zoomIn
        hud.contentColor = CurrentTheme.darkBackgroundColor
        
        Session.shared.login { [weak self] (result, error) in
            
            hud.hide(animated: true)
            guard error == nil else {
                DLog(error?.localizedDescription)
                self?.showOkCancelAlert(AppName, error?.localizedDescription, okTitle: OK, okActionBlock: nil)
                return
            }
            
            if let isSuccess = result as? Bool, isSuccess {
                // Touch ID configuration
                TouchIdHelper.shared.authenticationWithTouchID({ (sender, successfull, error) in
                    guard error == nil else {
                        // Handle Error
                        self?.showAlert(AppName, error?.localizedDescription ?? SomethingWentWrong)
                        return
                    }
                    
                    if successfull {
                        self?.configureTouchIdLogin()
                    }
                })
            }
        }
    }
    
    private func configureTouchIdLogin() {
    
        let isSuccess = Session.shared.saveUser()
        self.touchIdConfigurationBlock?(self, isSuccess)
        Session.shared.user.password = ""
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Button Action
    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        passwordTextField.resignFirstResponder()
        
        Session.shared.user.password = passwordTextField.text ?? ""
        verify()
    }
    
}
