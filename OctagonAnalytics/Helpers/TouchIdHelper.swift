//
//  TouchIdHelper.swift
//  KibanaGo
//
//  Created by Rameez on 2/20/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import Foundation
import LocalAuthentication
import SwiftKeychainWrapper

class TouchIdHelper {
    
    typealias AuthenticationBlock = (_ sender: Any?,_ success: Bool,_ error: Error?) -> Void

    static let shared = TouchIdHelper()
    
    var biomenticString: String {
        return isFaceIDSupported ? "Face ID" : "Touch ID"
    }
    
    func authenticationWithTouchID(_ completion: AuthenticationBlock?) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "Smart Login"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    DispatchQueue.main.async {
                        // success
                        completion?(self, true, nil)
                    }
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    DLog(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
//            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            DLog(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            
            let _ = self.evaluatePolicyFailErrorMessageForLA(errorCode: error.code, completion: completion)
        }
    }
    
    var isFaceIDSupported: Bool {
        if #available(iOS 11.0, *) {
            let localAuthenticationContext = LAContext()
            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return localAuthenticationContext.biometryType == .faceID
            }
        }
        return false
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int, completion: AuthenticationBlock?) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
               
            case LAError.passcodeNotSet.rawValue:
                message = "Passcode is not set on the device."

            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            case LAError.passcodeNotSet.rawValue:
                message = "Passcode is not set on the device."

            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: message])
        completion?(self, false, error)
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = ""
//            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}

protocol KeyChainConfigurationProtocol {
    func saveCredentials(_ userName: String, password: String) -> Bool
    func removeCredetials() -> Bool
}

extension KeyChainConfigurationProtocol {
    func saveCredentials(_ userName: String, password: String) -> Bool {
        let usernameSaved: Bool = KeychainWrapper.standard.set(userName, forKey: "username")
        let passwordSaved: Bool = KeychainWrapper.standard.set(password, forKey: "userPassword")
        
        return usernameSaved && passwordSaved
    }
    
    func getCredetials() -> (userName: String?, password: String?) {
        let usr = KeychainWrapper.standard.string(forKey: "username")
        let pwd = KeychainWrapper.standard.string(forKey: "userPassword")
        return (usr, pwd)
    }
    
    func removeCredetials() -> Bool {
        let usernameRemoved: Bool = KeychainWrapper.standard.removeObject(forKey: "username")
        let passwordRemoved: Bool = KeychainWrapper.standard.removeObject(forKey: "userPassword")
        return usernameRemoved && passwordRemoved
    }
    
}
