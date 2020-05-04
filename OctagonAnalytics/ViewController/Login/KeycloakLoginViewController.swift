//
//  KeycloakLoginViewController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 7/10/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import MBProgressHUD

class KeycloakLoginViewController: BaseViewController {

    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var mainTitleLabel: UILabel!

    fileprivate lazy var hud: MBProgressHUD = {
        return MBProgressHUD.refreshing(addedTo: self.view)
    }()

    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = CurrentTheme.darkBackgroundColorSecondary
        mainTitleLabel.style(CurrentTheme.textStyleWith(mainTitleLabel.font.pointSize, weight: .regular, color: CurrentTheme.secondaryTitleColor))
        loginButton.style(CurrentTheme.textStyleWith(loginButton.titleLabel?.font.pointSize ?? 20, weight: .regular, color: CurrentTheme.secondaryTitleColor))
        loginButton.style(.roundCorner(5.0, 0.0, .clear))
        loginButton.backgroundColor = CurrentTheme.standardColor.withAlphaComponent(0.5)

        if let web = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.loginWebView) as? OAuth2WebViewController {
            Session.shared.setupKeycloak(.embeddedWebView, webController: web)
        }
        
        MBProgressHUD.hide(for: view, animated: true)
        hud.show(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hud.hide(animated: true)
            self.showLogin()
        }
    }
    
    private func showLogin() {
        Session.shared.loginWithKeycloak { [weak self] (result, error) in
            guard error == nil else {
                self?.showAlert(AppName, error?.localizedDescription)
                return
            }
            
            NavigationManager.shared.showDashboardList()
        }
    }
    
    //MARK: Button Actions
    @IBAction func loginButtonAction(_ sender: UIButton) {
        showLogin()
    }
}

extension KeycloakLoginViewController {
    struct ViewControllerIdentifiers {
        static let loginWebView = "OAuth2WebViewController"
    }
    
}
