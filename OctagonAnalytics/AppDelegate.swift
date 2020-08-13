//
//  AppDelegate.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import LanguageManager_iOS
import SwiftDate
import OctagonAnalyticsService

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SwiftDate.defaultRegion = Region.local

        // Activate Localization
        LanguageManager.shared.defaultLanguage = LanguageManager.shared.deviceLanguage ?? .en
        
        SettingsBundleHelper.registerUserDefaults()
        UserDefaults.standard.set(true, forKey: LoginViewController.UserDefaultKeys.enableFaceIdPrompt)

        // Apply Theme
        ThemeManager.applyTheme()
        
        // Update Version & build number under Settings
        SettingsBundleHelper.setVersionAndBuildNumber()
        
        // Setup Initial entry point to the application based on configuration
        NavigationManager.shared.setupInitialEntryPoint()
        
        ServiceConfiguration.configure(Configuration.shared.baseUrl, version: Configuration.shared.kibVersion)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SettingsBundleHelper.registerUserDefaults()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return isIPhone ? .allButUpsideDown : .landscape
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let infoDict: [UIApplication.LaunchOptionsKey: Any] = [UIApplication.LaunchOptionsKey.url : url]
        
        if url.scheme?.caseInsensitiveCompare("com.octagonMobile.kibanaGoLaunchPad") == ComparisonResult.orderedSame {
            guard let dashboardId = url.query?.components(separatedBy: "=").last else { return true }
            Session.shared.dashboardIdToRedirect = dashboardId
            NotificationCenter.default.post(name: NSNotification.Name(NotificationNames.redirectToUrl), object: url, userInfo: infoDict)

        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: AGAppLaunchedWithURLNotification), object: url, userInfo: infoDict)
        }
        return true
    }
}

extension AppDelegate {
    struct ViewControllerIdentifiers {
        static let dashboardListingNavigationController = "DashboardListingNavigationController"
        static let keycloakLoginViewController = "KeycloakLoginViewController"
    }
    
    struct NotificationNames {
        static let redirectToUrl = "RedirectToUrl"
    }
}
