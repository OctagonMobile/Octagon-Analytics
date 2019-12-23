//
//  LoginViewController.swift
//  KibanaGo
//
//  Created by Rameez on 3/26/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit
import MBProgressHUD
import ActiveLabel
import LanguageManager_iOS

class LoginViewController: BaseViewController {

    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameErrorLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var termsAndCinditionLabel: ActiveLabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var touchIdButton: UIButton!
    @IBOutlet weak var differentUserButton: UIButton!
    @IBOutlet var diffUserHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userNameHolderView: UIView!
    @IBOutlet var touchIdButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var userNameSeparatorLine: UIView?
    @IBOutlet var passwordSeparatorLine: UIView?
    @IBOutlet weak var languageButton: UIButton?
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureLoginView()
        view.semanticContentAttribute = .forceLeftToRight
        view.backgroundColor = CurrentTheme.darkBackgroundColorSecondary
        
        let touchIdUserAvailable = Session.shared.isTouchIdUserAvailable()
        touchIdButton.isHidden = !touchIdUserAvailable
        if touchIdUserAvailable {
            showTouchIdLoginUI()
            
            let enableFaceIdPrompt = UserDefaults.standard.bool(forKey: UserDefaultKeys.enableFaceIdPrompt)
            if !TouchIdHelper.shared.isFaceIDSupported ||
                (TouchIdHelper.shared.isFaceIDSupported && enableFaceIdPrompt) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.loginWithTouchId()
                }
            }
        } else {
            showNormalLoginUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userNameLabel.style(CurrentTheme.textStyleWith(userNameLabel.font.pointSize, weight: .semibold, color: CurrentTheme.secondaryTitleColor))
        mainTitleLabel.style(CurrentTheme.textStyleWith(mainTitleLabel.font.pointSize, weight: .regular, color: CurrentTheme.secondaryTitleColor))
        let size = differentUserButton?.titleLabel?.font.pointSize ?? 18.0
        differentUserButton?.style(CurrentTheme.textStyleWith(size, weight: .medium, color: CurrentTheme.standardColor))
        loginButton.style(CurrentTheme.textStyleWith(loginButton.titleLabel?.font.pointSize ?? 20, weight: .regular, color: CurrentTheme.secondaryTitleColor))
        termsAndCinditionLabel.style(CurrentTheme.textStyleWith(termsAndCinditionLabel.font.pointSize, weight: .regular, color: CurrentTheme.secondaryTitleColor))
    }
    
    //MARK: Private Functions
    private func configureLoginView() {
        let theme = CurrentTheme

        updateLanguageButtonTitle()
        languageButton?.semanticContentAttribute = .forceLeftToRight

        loginButton.isEnabled = false
        loginButton.style(.roundCorner(5.0, 0.0, .clear))
        loginButton.backgroundColor = theme.standardColor.withAlphaComponent(0.5)
        
        userNameTextField.tintColor = theme.standardColor
        passwordTextField.tintColor = theme.standardColor
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "Username".localiz(),
                                                                     attributes: [NSAttributedString.Key.foregroundColor: theme.enabledStateBackgroundColor])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password".localiz(),
                                                                     attributes: [NSAttributedString.Key.foregroundColor: theme.enabledStateBackgroundColor])

        userNameTextField.style(theme.bodyTextStyle(theme.secondaryTitleColor))
        passwordTextField.style(theme.bodyTextStyle(theme.secondaryTitleColor))

        
        userNameErrorLabel.style(theme.errorTextStyle())
        passwordErrorLabel.style(theme.errorTextStyle())
        
        checkBoxButton.setImage(UIImage(named: checkBoxNormalIcon), for: .normal)
        checkBoxButton.setImage(UIImage(named: checkBoxSelectedIcon), for: .selected)
        
        userNameSeparatorLine?.backgroundColor = CurrentTheme.separatorColorSecondary
        passwordSeparatorLine?.backgroundColor = CurrentTheme.separatorColorSecondary
        setupTermsAndCondition()
    }
    
    private func setupTermsAndCondition() {
        let customType = ActiveType.custom(pattern: "Terms & Condition".localiz())
        termsAndCinditionLabel.enabledTypes = [customType]
        termsAndCinditionLabel.text = "I Agree to Terms & Condition".localiz()

        termsAndCinditionLabel.customColor[customType] = CurrentTheme.standardColor
        termsAndCinditionLabel.customSelectedColor[customType] = CurrentTheme.enabledStateBackgroundColor

        termsAndCinditionLabel.handleCustomTap(for: customType) { [weak self] element in
            DLog("Custom type tapped: \(element)")
            // Show Terms And Condition
            let termsController = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.termsAndConditionViewController) as? TermsAndConditionViewController ?? TermsAndConditionViewController()
            termsController.termsAndConditionString = "'By clicking ‘OK’ you agree to use this system or software only in accordance with MyCompany policies and regulations. Any misuse of this system or software may result in civil and/or criminal penalties.This system or software is only for use associated with the MyCompany. Any personal use or use outside of authorized clearance by the MyCompany may result in civil and/or criminal penalties."
            
            termsController.didAccept = { [weak self] (accepted) in
                guard let strongSelf = self else { return }
                strongSelf.checkBoxButton.isSelected = !accepted
                strongSelf.checkBoxButtonAction(strongSelf.checkBoxButton)
            }
            self?.present(termsController, animated: true, completion: nil)
        }

    }
    
    private func showNormalLoginUI() {
        differentUserButton.isHidden = true
        diffUserHeightConstraint.constant   =   0
        userNameLabel.isHidden = true
        userNameHolderView.isHidden = false
        userNameTextField.text = ""
        userNameLabel.text = ""
        touchIdButtonWidthConstraint.constant = 0
        checkBoxButton.isSelected = true
        checkBoxButtonAction(checkBoxButton)
    }

    private func showTouchIdLoginUI() {
        differentUserButton.isHidden = false
        diffUserHeightConstraint.constant   =   25
        userNameLabel.isHidden = false
        userNameHolderView.isHidden = true
        userNameTextField.text = Session.shared.touchIdUserName()
        userNameLabel.text = "Hello, ".localiz() + (Session.shared.touchIdUserName()?.capitalized ?? "")
        touchIdButtonWidthConstraint.constant = isIPhone ? 40 : 56
        touchIdButton.setImage(UIImage(named: authenticationIconName), for: .normal)
        checkBoxButton.isSelected = false
        checkBoxButtonAction(checkBoxButton)
    }
    
    //MARK: Button Action

    private func credentialsUpdated() {
        
        userNameErrorLabel.text = userNameTextField.text?.isEmpty == true ? "Please enter the Username".localiz() : ""
        passwordErrorLabel.text = passwordTextField.text?.isEmpty == true ? "Please enter the Password".localiz() : ""
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func isValidCredentials() -> Bool {
        return userNameTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
    }
    
    private func login() {
        
        guard !Session.shared.user.userName.isEmpty && !Session.shared.user.password.isEmpty else {
            showAlert("", "Invalid Credentials".localiz())
            return
        }
        
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
                UserDefaults.standard.set(false, forKey: UserDefaultKeys.enableFaceIdPrompt)
                // Reset Password
                Session.shared.user.password = ""
                // Go To Dashboard Listing
                NavigationManager.shared.showDashboardList()
            }
        }
    }
    
    private func loginWithTouchId() {
        view.endEditing(true)
        TouchIdHelper.shared.authenticationWithTouchID { [weak self] (sender, success, error) in
            
            guard error == nil else {
                self?.showAlert(AppName, error?.localizedDescription ?? SomethingWentWrong)
                return
            }
            
            if success {
                Session.shared.updateCredetialsForTouchIdLogin()
                self?.login()
            }
        }
    }
    
    private func updateLanguageButtonTitle() {
        let languageTitle = LanguageManager.shared.currentLanguage == .en ? "العربية" : "Eng"
        languageButton?.setTitle(languageTitle, for: .normal)
        let languageImg = LanguageManager.shared.currentLanguage == .en ? "uae" : "uk"
        languageButton?.setImage(UIImage(named: languageImg), for: .normal)
    }
    
    //MARK: Button Actions
    @IBAction func loginButtonAction(_ sender: UIButton) {
        credentialsUpdated()
        
        if isValidCredentials() {
            // Login
            Session.shared.user.userName = userNameTextField.text ?? ""
            Session.shared.user.password = passwordTextField.text ?? ""
            login()
        }
    }
    
    @IBAction func checkBoxButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        loginButton.isEnabled = sender.isSelected
        
        loginButton.backgroundColor = loginButton.isEnabled ? CurrentTheme.standardColor : CurrentTheme.standardColor.withAlphaComponent(0.5)

    }
    
    @IBAction func touchIdButtonAction(_ sender: UIButton) {
        
        guard loginButton.isEnabled else {
            showAlert("Terms & Condition".localiz(), "Please agree to terms & condition".localiz())
            return
        }
        loginWithTouchId()
    }
    
    @IBAction func signInAsDifferentUserButtonAction(_ sender: UIButton) {
        let biomenticString = TouchIdHelper.shared.biomenticString
        let alertMessage = String(format: "SmartLoginResetAlertMessage".localiz(), biomenticString)
        showOkCancelAlert("Sign in as different user".localiz(), alertMessage, okTitle: YES, okActionBlock: {
            
            // Remove user and reset UI
            Session.shared.removeUser()
            let touchIdUserAvailable = Session.shared.isTouchIdUserAvailable()
            self.touchIdButton.isHidden = !touchIdUserAvailable
            self.showNormalLoginUI()
            
        }, cancelTitle: NO, cancelActionBlock: nil)
    }
    
    @IBAction func languageButtonAction(_ sender: UIButton) {
        let code = LanguageManager.shared.currentLanguage == .en ? "ar" : "en"
        NavigationManager.shared.resetAppLanguage(code)
        updateLanguageButtonTitle()
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        credentialsUpdated()
        return true
    }
}

extension LoginViewController {
    struct ViewControllerIdentifiers {
        static let termsAndConditionViewController = "TermsAndConditionViewController"

    }
    
    struct UserDefaultKeys {
        static let enableFaceIdPrompt  =   "enableFaceIdPrompt"
    }
    
    var checkBoxNormalIcon: String {
        return CurrentTheme.isDarkTheme ? "Checkbox-Normal-Dark": "Checkbox-Normal"
    }
    
    var checkBoxSelectedIcon: String {
        return CurrentTheme.isDarkTheme ? "Checkbox-Selected-Dark": "Checkbox-Selected"
    }
    
    var authenticationIconName: String {
        var iconName = TouchIdHelper.shared.isFaceIDSupported ? "FaceIdIcon" : "TouchIdIcon"
        switch CurrentTheme {
        case .light: break
        case .dark: iconName += "-Dark"
        }
        return iconName
    }

}
