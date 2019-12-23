//
//  Utility.swift
//  KibanaGo
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import UIKit

func DLog(_ message: String?, function: String = #function) {
    #if DEBUG
        if let mess = message {
            print("\(function): \(mess)")
        }
    #endif
}

let AppName         =   (Bundle.main.displayName ?? "Kibana Go").localiz()
let YES             =   "Yes".localiz()
let NO              =   "No".localiz()
let OK              =   "Ok".localiz()
let Cancel          =   "Cancel".localiz()
let SomethingWentWrong = "Something went wrong".localiz()

var CurrentTheme = ThemeManager.currentTheme()

let isIPhone                =   UIDevice.current.userInterfaceIdiom == .phone
var isLandscapeMode: Bool {
    return UIApplication.shared.statusBarOrientation.isLandscape
}

let keyCloakEnabled = SettingsBundleHelper.isKeycloakLoginEnabled()
let authenticationType = SettingsBundleHelper.authType
