//
//  ThemeManager.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/24/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import PopupDialog

enum Theme: String {
    
    case light = "Light", dark = "Dark"
    
    //MARK: Colors
    //Title Colors
    var titleColor: UIColor {
        switch self {
        case .light: return UIColor.Neutral.mineShaft
        case .dark: return UIColor.white
        }
    }

    var secondaryTitleColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.white
        }
    }
    
    var selectedTitleColor: UIColor {
        switch self {
        case .light: return UIColor.Neutral.mineShaft
        case .dark: return UIColor.black
        }
    }
    
    var standardColor: UIColor {
        switch self {
        case .light: return UIColor.Primary.viking
        case .dark: return UIColor.DarkThemeColors.buttonColor
        }
    }

    var drillDownButtonBackgroundColor: UIColor {
        switch CurrentTheme {
        case .light: return .clear
        case .dark: return .white
        }
    }

    var separatorColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.Neutral.lilyWhite
        }
    }
    
    var separatorColorSecondary: UIColor {
        switch self {
        case .light: return UIColor.Primary.lightStateGray
        case .dark: return UIColor.white
        }
    }

    var borderColor: UIColor {
        switch self {
        case .light: return UIColor.Neutral.lilyWhite
        case .dark: return UIColor.DarkThemeColors.lightBackgroundColor
        }
    }
    
    var sliderTrackColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.Neutral.iron
        }
    }

    
    // Background Colors
    var darkBackgroundColor: UIColor {
        switch self {
        case .light: return UIColor.Primary.elephant
        case .dark: return UIColor.black
        }
    }

    var darkBackgroundColorSecondary: UIColor {
        switch self {
        case .light: return UIColor.Primary.elephant
        case .dark: return UIColor.DarkThemeColors.darkBackgroundColor
        }
    }

    var lightBackgroundColor: UIColor {
        switch self {
        case .light: return UIColor.Primary.antiFlash
        case .dark: return UIColor.DarkThemeColors.lightBackgroundColor
        }
    }
    
    var cellBackgroundColor: UIColor {
        switch self {
        case .light: return UIColor.white
        case .dark: return UIColor.black
        }
    }
    
    var cellBackgroundColorSecondary: UIColor {
        switch self {
        case .light: return UIColor.Neutral.whiteSmoke
        case .dark: return UIColor.black
        }
    }
    
    var cellBackgroundColorPair: [UIColor] {
        switch self {
        case .light: return [UIColor.white, UIColor.Primary.antiFlash.withAlphaComponent(0.5)]
        case .dark: return [.black, UIColor.black.withAlphaComponent(0.5)]
        }
    }
    
    var headerViewBackground: UIColor {
        switch self {
        case .light: return UIColor.Primary.iceberg
        case .dark: return UIColor.ChartColorsDarkSet1.sixth
        }
    }
    
    var headerViewBackgroundColorSecondary: UIColor {
        switch self {
        case .light: return UIColor.white
        case .dark: return UIColor.DarkThemeColors.lightBackgroundColor
        }
    }

    var enabledStateBackgroundColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.Primary.lightStateGray
        }
    }
    
    
    var disabledStateBackgroundColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.Neutral.doveGray
        }
    }
    
    var filterInvertDisableColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.Primary.cadetBlue
        }
    }

    var errorMessageColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.Secondary.sunglo
        }
    }

    var chartColors1: [UIColor] {
        switch self {
        case .light: return UIColor.ChartColorsSet1.all
        case .dark: return UIColor.ChartColorsDarkSet1.all
        }
    }

    var chartColors2: [UIColor] {
        switch self {
        case .light: return UIColor.ChartColorsSet2.all
        case .dark: return UIColor.ChartColorsDarkSet2.all
        }
    }

    var chartColors3: [UIColor] {
        switch self {
        case .light: return UIColor.ChartColorsSet3.all
        case .dark: return UIColor.ChartColorsDarkSet3.all
        }
    }
    
    private var firstSetChartColors: [UIColor] {
        return chartColors1 + chartColors2 + chartColors3 + UIColor.ChartColorsSetVolcano.all + UIColor.ChartColorsSetSunsetOrange.all
    }
    
    private var secondSetChartColors: [UIColor] {
        return UIColor.ChartColorsCalendulaGold.all + UIColor.ChartColorsSunriseYellow.all + UIColor.ChartColorsLime.all + UIColor.ChartColorsCyan.all
    }

    var allChartColors: [UIColor] {
        return firstSetChartColors + secondSetChartColors
    }

    var gaugeRangeColors: [UIColor] {
        return UIColor.GaugeRangeColorsSet.all + firstSetChartColors
    }
    
    var mapTrackingColors: [UIColor] {
        switch self {
        case .light, .dark: return UIColor.MapTrackingColors.all
        }
    }

    var mapTrackingUserPathColors: [UIColor] {
        switch self {
        case .light, .dark: return UIColor.MapTrackingUserPathColors.all
        }
    }
    
    var datePickerSelectedStateColor: UIColor {
        switch self {
        case .light: return UIColor.colorFromHexString("4F5864")
        case .dark: return UIColor.colorFromHexString("4F5864")
        }
    }
    
    var futureDateTextColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.Neutral.silverChalice
        }
    }

    var worldMapColor: UIColor {
        switch self {
        case .light: return UIColor.colorFromHexString("7fc5c4")
        case .dark: return UIColor.ChartColorsDarkSet1.sixth
        }
    }
    
    var tabBarBackgroundColor: UIColor {
        switch self {
        case .light: return UIColor.Primary.elephant
        case .dark: return .black
        }
    }

    var tabBarTitleColor: UIColor {
        switch self {
        case .light: return .white
        case .dark: return UIColor.colorFromHexString("#0091FF")
        }
    }
    
    var tutorialButtonColor: UIColor {
        switch self {
        case .light: return UIColor.colorFromHexString("59c8d3")
        case .dark: return UIColor.systemBlue
        }
    }

    var tutorialHighlightedButtonColor: UIColor {
        switch self {
        case .light: return UIColor.colorFromHexString("287982")
        case .dark: return UIColor.colorFromHexString("004AB2")
        }
    }

    var textFieldBorderColor: UIColor {
        switch self {
        case .light, .dark: return UIColor.colorFromHexString("EAEAEA")
        }
    }

    var sliderLineColor: UIColor {
        switch self {
        case .light: return UIColor.colorFromHexString("EAEAEA")
        case .dark: return UIColor.DarkThemeColors.lightBackgroundColor
        }
    }
    
    var controlsApplyButtonBackgroundColor: UIColor {
        switch self {
        case .light: return UIColor.Primary.viking
        case .dark: return UIColor.white
        }
    }

    var controlsApplyButtonTitleColor: UIColor {
        switch self {
        case .light: return UIColor.white
        case .dark: return UIColor.DarkThemeColors.buttonColor
        }
    }

    var popOverListSelectionColor: UIColor {
        switch self {
        case .light: return UIColor.Primary.antiFlash
        case .dark: return UIColor.DarkThemeColors.darkBackgroundColor
        }
    }
    
    func barChartRaceColors(_ total: Int) -> [UIColor] {
        return UIColor.BarChartRaceColorsSet.colors(total)
    }

    //MARK: Styles
    /// Styles
    func title1TextStyle(_ color: UIColor? = nil) -> TextStyle {
        
        guard color == nil else { return textStyleWith(28.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(28.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(28.0, weight: .regular, color: .white)
        }
    }
    
    func title2TextStyle(_ color: UIColor? = nil) -> TextStyle {
        
        guard color == nil else { return textStyleWith(22.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(22.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(22.0, weight: .regular, color: .white)
        }
    }
    
    func title3TextStyle(_ color: UIColor? = nil) -> TextStyle {
        
        guard color == nil else { return textStyleWith(20.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(20.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(20.0, weight: .regular, color: .white)
        }
    }

    func headLineTextStyle(_ color: UIColor? = nil) -> TextStyle {
        
        guard color == nil else { return textStyleWith(17.0, weight: .semibold, color: color!) }

        switch self {
        case .light: return textStyleWith(17.0, weight: .semibold, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(17.0, weight: .semibold, color: .white)
        }
    }
    
    func bodyTextStyle(_ color: UIColor? = nil) -> TextStyle {
        guard color == nil else { return textStyleWith(17.0, weight: .regular, color: color!) }
        
        switch self {
        case .light: return textStyleWith(17.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(17.0, weight: .regular, color: .white)
        }
    }

    func calloutTextStyle(_ color: UIColor? = nil) -> TextStyle {
        guard color == nil else { return textStyleWith(16.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(16.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(16.0, weight: .regular, color: .white)
        }
    }

    func subHeadTextStyle(_ color: UIColor? = nil) -> TextStyle {
        guard color == nil else { return textStyleWith(15.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(15.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(15.0, weight: .regular, color: .white)
        }
    }

    func footNoteTextStyle(_ color: UIColor? = nil) -> TextStyle {
        guard color == nil else { return textStyleWith(13.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(13.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(13.0, weight: .regular, color: .white)
        }
    }
    
    func caption1TextStyle(_ color: UIColor? = nil) -> TextStyle {
        
        guard color == nil else { return textStyleWith(12.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(12.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(12.0, weight: .regular, color: .white)
        }
    }

    func caption2TextStyle(_ color: UIColor? = nil) -> TextStyle {
        guard color == nil else { return textStyleWith(11.0, weight: .regular, color: color!) }

        switch self {
        case .light: return textStyleWith(11.0, weight: .regular, color: UIColor.Neutral.mineShaft)
        case .dark: return textStyleWith(11.0, weight: .regular, color: .white)
        }
    }

    func errorTextStyle(_ color: UIColor = CurrentTheme.errorMessageColor) -> TextStyle {
        switch self {
        case .light: return textStyleWith(14.0, weight: .regular, color: color)
        case .dark: return textStyleWith(14.0, weight: .regular, color: color)
        }
    }

    // Generic Method to generae Style
    func textStyleWith(_ size: CGFloat, weight: UIFont.Weight, color: UIColor? = nil) -> TextStyle {
        let font = UIFont.withSize(size, weight: weight)
        
        guard color == nil else { return TextStyle(font: font, color: color!) }
        
        switch self {
        case .light:
            return TextStyle(font: font, color: UIColor.Neutral.mineShaft)
        case .dark:
            return TextStyle(font: font, color: .white)
        }
    }

    //Customizing the Navigation Bar
    var barStyle: UIBarStyle {
        switch self {
        case .light: return .default
        case .dark: return .black
        }
    }
    
    var navigationBackgroundImage: UIImage? {
        switch self {
        case .light:
            let color = darkBackgroundColor.withAlphaComponent(0.8)
            let image = UIImage.imageFromColor(color: color)
            return image
        case .dark:
            return UIImage.imageFromColor(color: .black)
        }
    }

    var isTranslucent: Bool {
        switch self {
        case .light, .dark: return true
        }
    }
}

extension Theme {
    var isDarkTheme: Bool {
        return self == .dark
    }
}

class ThemeManager: NSObject {

    // ThemeManager
    static func currentTheme() -> Theme {
        if let storedTheme = UserDefaults.standard.string(forKey: ThemeKeys.selectedTheme) {
            return Theme(rawValue: storedTheme)!
        } else {
            return .dark
        }
    }
    
    static func applyTheme(theme: Theme = SettingsBundleHelper.selectedTheme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: ThemeKeys.selectedTheme)
        UserDefaults.standard.synchronize()
        
        // Apply the main color to the tintColor property of your application’s window.
        UIApplication.shared.windows.forEach({ $0.tintColor = theme.secondaryTitleColor})

        UINavigationBar.appearance().isTranslucent = theme.isTranslucent
        UINavigationBar.appearance().barTintColor = theme.darkBackgroundColor
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)

        UITabBar.appearance().barTintColor = theme.tabBarBackgroundColor
        UITabBar.appearance().tintColor = theme.tabBarTitleColor
        
        UINavigationBar.appearance().titleTextAttributes =
            [NSAttributedString.Key.font:UIFont.withSize(17, weight: .semibold) as AnyObject,
             NSAttributedString.Key.foregroundColor:theme.secondaryTitleColor]
        setupPopUpDialog(theme)
    }

    static func setupPopUpDialog(_ theme: Theme) {
        let overlayAppearance = PopupDialogOverlayView.appearance()
        
        overlayAppearance.color       = theme.darkBackgroundColor
        overlayAppearance.blurRadius  = 20
        overlayAppearance.blurEnabled = true
        overlayAppearance.liveBlurEnabled    = false
        overlayAppearance.opacity     = 0.6
    }
}

struct ThemeKeys {
    static let selectedTheme = "selectedTheme"
}
