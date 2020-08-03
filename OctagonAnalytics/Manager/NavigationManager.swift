//
//  NavigationManager.swift
//  OctagonAnalytics
//
//  Created by Rameez on 3/26/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import UIKit
import LanguageManager_iOS

class NavigationManager: NSObject {

    /**
     Returns the shared default object.
     */
    static let shared = NavigationManager()

    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(NavigationManager.sessionTimeOut(_ :)), name: NSNotification.Name(Constant.sessionTimeOutNotification), object: nil)
    }
    
    //MARK:
    @objc private func sessionTimeOut(_ notify: Notification) {

        guard !(UIApplication.topViewController() is LoginViewController) else { return }
        Session.shared.isLoggedIn = false
        showLoginScreen()
    }
    
    func showLoginScreen() {
        let loginIdentifier = keyCloakEnabled ? ViewControllerIdentifiers.keycloakLoginViewController : ViewControllerIdentifiers.loginViewController
        let loginViewController = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: loginIdentifier)
        changeRootViewController(loginViewController)
    }
    
    func showDashboardList() {
        // Switch to Dashboard list screen
        let identifier = ViewControllerIdentifiers.dashboardTabBarController
        
        let mainController = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: identifier)
        changeRootViewController(mainController)
    }
    
    func changeRootViewController(_ toViewController: UIViewController) {
        
        UIApplication.appKeyWindow?.rootViewController = toViewController
        
        
        guard let window = UIApplication.appKeyWindow else { return }
        
        guard let rootViewController = window.rootViewController else { return }
        
        toViewController.view.frame = rootViewController.view.frame
        toViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 1.0, options: .transitionFlipFromRight, animations: {
            window.rootViewController = toViewController
        }, completion: nil)

    }

    func showSettingsScreen() {
        let settingsScreen = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.settingsViewController)
        guard let window = UIApplication.appKeyWindow else { return }
        
        guard let rootViewController = window.visibleViewController() else { return }
        if isIPhone {
            rootViewController.navigationController?.pushViewController(settingsScreen, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: settingsScreen)
            navController.modalPresentationStyle = .formSheet
            rootViewController.present(navController, animated: true, completion: nil)
        }
    }
    
    func setupInitialEntryPoint() {
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        
        let initialController = getInitialEntryPoint ()
        window.rootViewController = initialController
    }
    
    
    func showTutorial(_ showAutoFill: Bool = true,_ autoFillActionBlock: TutorialButtonActionBlock? = nil) {
        guard let tutorialViewCtr = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.tutorialViewController) as? TutorialViewController else { return }
        guard let window = UIApplication.appKeyWindow else { return }
        guard let rootViewController = window.visibleViewController() else { return }

        tutorialViewCtr.modalPresentationStyle = .overCurrentContext
        tutorialViewCtr.showAutoFill = showAutoFill
        tutorialViewCtr.tutorialAutoFillActionBlock = autoFillActionBlock
        rootViewController.present(tutorialViewCtr, animated: true, completion: nil)
    }

    func showBarchartRace(_ navController: UINavigationController, data: [VideoContent], config: VideoConfigContent?) {
        guard let barchartRaceVC = StoryboardManager.shared.storyBoard(.timelineVideo).instantiateViewController(withIdentifier: ViewControllerIdentifiers.barChartRaceViewController) as? BarChartRaceViewController else { return }
        barchartRaceVC.barData = data
        barchartRaceVC.videoConfig = config
        navController.pushViewController(barchartRaceVC, animated: true)
    }
    
    func showVectorMapTimeline(_ navController: UINavigationController,
                               data: [VectorMapContainer]) {
        let vectorMap = VectorTimelineViewController.init(nibName: String(describing: VectorTimelineViewController.self), bundle: nil)
        vectorMap.hidesBottomBarWhenPushed = true
        vectorMap.vectorMapData = data
        navController.pushViewController(vectorMap, animated: true)
    }
    
    private func getInitialEntryPoint () -> UIViewController {

        var identifier: String
        if authenticationType == .none || Session.shared.isLoggedIn {
            identifier = ViewControllerIdentifiers.dashboardTabBarController
        } else if authenticationType == .basic {
            identifier = ViewControllerIdentifiers.loginViewController
        } else {
            identifier = ViewControllerIdentifiers.keycloakLoginViewController
        }
        
        let initialController = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: identifier)
        return initialController
    }
    
    func resetAppLanguage(_ code: String) {
        let selectedLang = Languages(rawValue: code) ?? Languages.deviceLanguage
        let entryPoint = NavigationManager.shared.getInitialEntryPoint()
        LanguageManager.shared.setLanguage(language: selectedLang, rootViewController: entryPoint) { (view) in
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
            view.alpha = 0
        }
    }
}

extension NavigationManager {

    func showDatePicker(_ sourceView: UIView, rect: CGRect,barButton: UIBarButtonItem? = nil, mode: DatePickerMode = .quickPicker, quickPickerValue: QuickPicker? = nil, fromDate: Date? = nil, toDate: Date? = nil, selectionBlock: DateSelectionBlock?) {
        let popOverContent = StoryboardManager.shared.storyBoard(.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.multiDatePickerViewController) as? MultiDatePickerViewController ?? MultiDatePickerViewController()
        popOverContent.preferredContentSize = CGSize(width: 660, height: 520)
        popOverContent.currentPickerMode = .calendarPicker //mode // Always show calendar picker (disabled because JTCalendar pod has refresh issue)
        popOverContent.dateSelectionBlock = selectionBlock
        popOverContent.preSelectedQuickPickerDate = quickPickerValue
        popOverContent.quickPickerTheme = Constants.quickPickerTheme
        popOverContent.calendarPickerTheme = Constants.calendarDatePickerTheme

        guard let window = UIApplication.appKeyWindow else { return }
        
        guard let rootViewController = window.rootViewController else { return }

        if isIPhone {
            rootViewController.present(popOverContent, animated: true, completion: nil)
        } else {
            
            let nav = UINavigationController(rootViewController: popOverContent)
            nav.modalPresentationStyle = UIModalPresentationStyle.popover
            nav.isNavigationBarHidden = true
            let popover = nav.popoverPresentationController
            
            popover?.permittedArrowDirections = .any
            popover?.backgroundColor = CurrentTheme.darkBackgroundColor.withAlphaComponent(0.8)
            
            if barButton != nil {
                popover?.barButtonItem = barButton
            } else {
                popover?.sourceRect = rect
                popover?.sourceView = sourceView
                
            }
            rootViewController.present(nav, animated: true, completion: nil)
        }
    }
}

extension NavigationManager {
    struct ViewControllerIdentifiers {
        static let loginViewController  = "LoginViewController"
        static let multiDatePickerViewController = "MultiDatePickerViewController"
        static let settingsViewController  = "SettingsViewController"
        static let keycloakLoginViewController = "KeycloakLoginViewController"
        static let dashboardListingNavigationController = "DashboardListingNavigationController"
        static let dashboardTabBarController = "DashboardTabBarController"
        static let tutorialViewController  = "TutorialViewController"
        static let barChartRaceViewController = "BarChartRaceViewController"
    }

    struct Constants {
        static var quickPickerTheme: QuickDatePickerTheme {
            var theme = QuickDatePickerTheme()
            theme.backgroundColorNormal      = CurrentTheme.enabledStateBackgroundColor.withAlphaComponent(0.30)
            theme.backgroundColorSelected    = CurrentTheme.enabledStateBackgroundColor
            theme.backgroundColorHighlighted = CurrentTheme.darkBackgroundColor.withAlphaComponent(0.30)
            theme.font                       = UIFont.withSize(15, weight: .regular)
            return theme
        }
        
        static var calendarDatePickerTheme: CalendarDatePickerTheme {
            var theme = CalendarDatePickerTheme()
            theme.textColorSelected = CurrentTheme.selectedTitleColor
            theme.centerDateColor = CurrentTheme.enabledStateBackgroundColor
            theme.applyButtonTitleColor = CurrentTheme.standardColor
            theme.clearButtonBackgroundColor = CurrentTheme.enabledStateBackgroundColor.withAlphaComponent(0.3)
            theme.applyButtonBackgroundColor = CurrentTheme.secondaryTitleColor
            theme.errorMessageColor = CurrentTheme.errorMessageColor
            theme.dayLabelFont = UIFont.withSize(17.0, weight: .regular)
            theme.actionButtonFont = UIFont.withSize(15.0, weight: .regular)
            theme.titleLabelFont = UIFont.withSize(15.0, weight: .bold)
            return theme
        }
    }

}

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController  = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKind(of: UINavigationController.self) {
            
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
            
        } else if vc.isKind(of: UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

