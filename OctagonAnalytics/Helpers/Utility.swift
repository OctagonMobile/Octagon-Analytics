//
//  Utility.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

func DLog(_ message: String?, function: String = #function) {
    #if DEBUG
//        if let mess = message {
//            print("\(function): \(mess)")
//        }
    #endif
}

let AppName         =   (Bundle.main.displayName ?? "Octagon Analytics").localiz()
let YES             =   "Yes".localiz()
let NO              =   "No".localiz()
let OK              =   "Ok".localiz()
let Cancel          =   "Cancel".localiz()
let SomethingWentWrong = "Something went wrong".localiz()

var CurrentTheme = ThemeManager.currentTheme()

let isIPhone                =   UIDevice.current.userInterfaceIdiom == .phone
var isLandscapeMode: Bool {
    
    return UIApplication.shared.windows
        .first?
        .windowScene?
        .interfaceOrientation
        .isLandscape ?? false
}

let keyCloakEnabled = SettingsBundleHelper.isKeycloakLoginEnabled()
let authenticationType = SettingsBundleHelper.authType


struct AppOrientationUtility {

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

}
