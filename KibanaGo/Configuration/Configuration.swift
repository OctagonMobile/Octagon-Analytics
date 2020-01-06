//
//  Configuration.swift
//  KibanaGo
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import Foundation

fileprivate let defScheme   =   "SCHEME"
fileprivate let defBaseUrl  =   "BASE_URL"
fileprivate let defPort     =   "PORT"

enum Environment: String {
    
    case development    = "Development"
    case staging        = "Staging"
    case production     = "Production"
    
    
    var baseUrl: String {
        return SettingsBundleHelper.customUrl()
    }
        
    var mapBaseUrl: String {
        switch self {
        case .development, .staging:
            return "MAP_URL"
        case .production:
            return "MAP_URL"
        }
    }
    
    var imageHashBaseUrl: String {
        switch self {
        case .development, .staging:
            return "IMAGE_HASH_URL"
        case .production:
            return "IMAGE_HASH_URL"
        }
    }

    var keyCloakClientId: String {
        return "KEYCLOAK_CLIENT_ID"
    }
    
    var keyCloakClientSecret: String {
        return "KEYCLOAK_CLIENT_SECRET"
    }

    var keyCloakHost: String {
        return "KEYCLOAK_HOST"
    }

    var keyCloakRealm: String {
        return "KEYCLOAK_REALM"
    }

}

class Configuration {
    
    static let shared = Configuration()
    
    lazy var environment: Environment = {
        guard let selectedEnvironment = Bundle.main.object(forInfoDictionaryKey: "Environment") as? String else {
            return Environment.production
        }
        
        switch selectedEnvironment {
        case Environment.development.rawValue:
            return Environment.development
        case Environment.staging.rawValue:
            return Environment.staging
        case Environment.production.rawValue:
            return Environment.production
        default:
            return Environment.production
        }
    }()
    
    var baseUrl: String {
        return Configuration.shared.environment.baseUrl
    }
    
    var mapBaseUrl: String {
        return Configuration.shared.environment.mapBaseUrl
    }

    var imageHashBaseUrl: String {
        return Configuration.shared.environment.imageHashBaseUrl
    }

    var keyCloakClientId: String {
        return Configuration.shared.environment.keyCloakClientId
    }
    
    var keyCloakClientSecret: String {
        return Configuration.shared.environment.keyCloakClientSecret
    }
    
    var keyCloakHost: String {
        return Configuration.shared.environment.keyCloakHost
    }
    
    var keyCloakRealm: String {
        return Configuration.shared.environment.keyCloakRealm
    }

}

class SettingsBundleHelper {
    struct SettingsBundleKeys {
        static let baseUrl = "base_url"
        static let portNumber = "port"
        static let protocolKey = "protocol"
        static let authentication = "Authentication"
        static let themeKey = "theme"
        static let enableXPack = "enableXPack"
    }
    
    enum AuthenticationType: String {
        case basic      =   "Basic"
        case keycloak   =   "Keycloak"
        case none       =   "None"
    }
    
    class func registerUserDefaults() {
        let dict:[String: Any] = [:]
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: dict)
        
        if userDefaults.string(forKey: SettingsBundleKeys.protocolKey) == nil {
            userDefaults.set(defScheme, forKey: SettingsBundleKeys.protocolKey) // eg. http or https
        }

        if userDefaults.string(forKey: SettingsBundleKeys.baseUrl) == nil {
            userDefaults.set(defBaseUrl, forKey: SettingsBundleKeys.baseUrl) // eg.  1.1.1.1
        }
        if userDefaults.string(forKey: SettingsBundleKeys.portNumber) == nil {
            userDefaults.set(defPort, forKey: SettingsBundleKeys.portNumber) // eg. 1111
        }

        if userDefaults.string(forKey: SettingsBundleKeys.themeKey) == nil {
            userDefaults.set("Light", forKey: SettingsBundleKeys.themeKey)
        }
        
        if userDefaults.string(forKey: SettingsBundleKeys.authentication) == nil {
            userDefaults.set(AuthenticationType.basic.rawValue, forKey: SettingsBundleKeys.authentication)
        }

        userDefaults.synchronize()
    }
    
    static var authType: AuthenticationType {
        guard let authType = UserDefaults.standard.string(forKey: SettingsBundleKeys.authentication) else {
            return .none
        }
        return AuthenticationType(rawValue: authType) ?? .none
    }
    
    static func isLoginEnabled() -> Bool {
        return authType == AuthenticationType.basic
    }

    static func isKeycloakLoginEnabled() -> Bool {
        return authType == AuthenticationType.keycloak
    }

    static func isXpackEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: SettingsBundleKeys.enableXPack)
    }
    
    static func customUrl() -> String {
        let protocolName: String    = UserDefaults.standard.string(forKey: SettingsBundleKeys.protocolKey) ?? ""
        let url: String             = UserDefaults.standard.string(forKey: SettingsBundleKeys.baseUrl) ?? ""
        let port: String            = UserDefaults.standard.string(forKey: SettingsBundleKeys.portNumber) ?? ""
        
        UserDefaults.standard.synchronize()
        return "\(protocolName)://\(url):\(port)"
    }
    
    static var selectedTheme: Theme {
        if let themeName = UserDefaults.standard.string(forKey: SettingsBundleKeys.themeKey) {
            return Theme(rawValue: themeName) ?? Theme.light
        }
        return Theme.light
    }
    
    class func setVersionAndBuildNumber() {
        if let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            UserDefaults.standard.set(version, forKey: "version_preference")
        }
        if let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            UserDefaults.standard.set(build, forKey: "build_preference")
        }
    }

}

