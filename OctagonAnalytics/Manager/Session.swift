//
//  Session.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/19/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import AeroGearHttp
import OctagonAnalyticsService

class Session: NSObject {

    /** User*/
    
    var user: User = User()
    
    /** TRUE if user already logged in otherwise FASLE*/
    var isLoggedIn: Bool    =   false
    
    /**
     Returns the shared default object.
     */
    static let shared = Session()
    
    var dashboardIdToRedirect: String?
    
    var appliedFilters: [FilterProtocol]    = []
    
    /** Keycloak Access token */
    var keyCloakAccessToken: String? {
        return oauth2Module?.oauth2Session.accessToken
    }
    
    fileprivate var config: KeycloakConfig?
    fileprivate var oauth2Module:  KeycloakOAuth2Module?

    func addFilters(_ filter: FilterProtocol) {
        if let matchedFilter = appliedFilters.filter( {($0.hasSameFieldName(filter))} ).first {
            removeFilter(matchedFilter)
        }

        appliedFilters.append(filter)
    }
    
    func removeFilter(_ filter: FilterProtocol) {
        guard containsFilter(filter) else { return }
        
        appliedFilters = appliedFilters.filter( {!($0.isEqual(filter))} )
    }
    
    func containsFilter(_ filter: FilterProtocol) -> Bool {
        return appliedFilters.filter{ $0.isEqual(filter) }.count > 0
    }
    
    //MARK:
    func login(_ completion: CompletionBlock?) {
        // Service Call here
        ServiceProvider.shared.loginWith(user.userName, password: user.password) { (response, error) in
            guard error == nil else {
                completion?(false, error?.asNSError)
                return
            }

            self.isLoggedIn = true
            completion?(true, nil)
        }
    }
    
    func logout(_ completion:CompletionBlock?) {
        // Service Call here
        ServiceProvider.shared.logout { (res, error) in
            completion?(res, error?.asNSError)
        }
        self.isLoggedIn = false
    }
    
    //MARK: Keycloak
    func setupKeycloak(_ webViewType: Config.WebViewType, webController: OAuth2WebViewController?) {
        
        let configuration = Configuration.shared
        config = KeycloakConfig(clientId: configuration.keyCloakClientId, clientSecret: configuration.keyCloakClientSecret,  host: configuration.keyCloakHost, realm: configuration.keyCloakRealm, isOpenIDConnect: true)
        
        guard let config = config else { return }
        oauth2Module = AccountManager.addKeycloakAccount(config: config)
        if let oauth2Module = oauth2Module, !oauth2Module.isAuthorized() {
            logoutKeycloak(nil)
        }
        
        if let web = webController {
            config.webView = webViewType
            oauth2Module?.webView = web
        }
    }

    func loginWithKeycloak(_ completion: CompletionBlock?) {
        let http = Http()
        http.authzModule = oauth2Module
        
        oauth2Module?.login { (accessToken, claims, error) in
            guard error == nil else {
                completion?(nil, error)
                return
            }

            self.isLoggedIn = true
            completion?(accessToken, nil)
        }
    }
    
    func logoutKeycloak(_ completion: CompletionBlock?) {
        oauth2Module?.revokeAccess { [weak self] (res, error) in
            self?.oauth2Module?.oauth2Session.clearTokens()
            self?.isLoggedIn = false
            completion?(true, error)
        }
    }

    func refreshToken(_ completion: @escaping CompletionBlock) {
        // Refresh the access token if required
        guard oauth2Module?.oauth2Session.tokenIsNotExpired() == false else {
            completion(keyCloakAccessToken, nil)
            return
        }
        oauth2Module?.refreshAccessToken(completionHandler: completion)
    }
}

extension Session: KeyChainConfigurationProtocol {
    func updateCredetialsForTouchIdLogin() {
        let cred = getCredetials()
        if let userName = cred.userName, let password = cred.password {
            user.userName   =   userName
            user.password   =   password
        }
    }
    
    @discardableResult
    func saveUser() -> Bool {
        let user = Session.shared.user
        return saveCredentials(user.userName, password: user.password)
    }
    
    @discardableResult
    func removeUser() -> Bool {
        return removeCredetials()
    }
    

    func touchIdUserName() -> String? {
        let cred = getCredetials()
        return cred.userName
    }
    
    func isTouchIdUserAvailable() -> Bool {
        let cred = getCredetials()
        if let userName = cred.userName, let password = cred.password {
            return !userName.isEmpty && !password.isEmpty
        }
        return false
    }
}

extension Session {
    struct UrlComponant {
        static let login = "v1/auth/login"
        static let logout = "v1/auth/logout"
    }
    
    struct Version {
        static let version552    =   "5.5.2-SNAPSHOT"
    }
}
