//
//  StyleGuide.swift
//  OctagonAnalytics
//
//  Created by Rameez on 1/22/18.
//  Copyright © 2018 Octagon Mobile. All rights reserved.
//

import Foundation

////////////////////////////////////// Text Styling //////////////////////////////////////
struct TextStyle {
    let font: UIFont
    let color: UIColor
}

protocol TextStyling {
    func style(_ style: TextStyle)
}

extension UILabel: TextStyling {
    
    func style(_ style: TextStyle) {
        font        = style.font
        textColor   = style.color
    }
}

extension UIButton: TextStyling {
    
    func style(_ style: TextStyle) {
        titleLabel?.font = style.font
        setTitleColor(style.color, for: .normal)
    }
}

extension UITextField: TextStyling {
    
    func style(_ style: TextStyle) {
        font = style.font
        textColor = style.color
    }
}

extension UITextView: TextStyling {
    
    func style(_ style: TextStyle) {
        font = style.font
        textColor = style.color
    }
}


////////////////////////////////////// View Styling //////////////////////////////////////

struct ViewStyle {
    
    struct LayerStyle {
        
        struct BorderStyle {
            let color: UIColor
            let width: CGFloat
        }
        
        struct ShadowStyle {
            let color: UIColor
            let radius: CGFloat
            let offset: CGSize
            let opacity: Float
        }
        
        let masksToBounds: Bool?
        let cornerRadius: CGFloat?
        let borderStyle: BorderStyle?
        let shadowStyle: ShadowStyle?
    }
    
    let backgroundColor: UIColor?
    let tintColor: UIColor?
    let layerStyle: LayerStyle?
}

extension ViewStyle {
    
    static func roundCorner(_ cornerRadius: CGFloat = 5.0,_ borderWidth: CGFloat = 2.0, _ borderColor: UIColor = UIColor.white) -> ViewStyle {
        let borderStyle = ViewStyle.LayerStyle.BorderStyle(color: borderColor, width: borderWidth)
        let layerStyle = ViewStyle.LayerStyle(masksToBounds: true, cornerRadius: cornerRadius, borderStyle: borderStyle, shadowStyle: nil)
        return ViewStyle(backgroundColor: nil, tintColor: nil, layerStyle: layerStyle)
    }
    
    static func shadow(_ radius: CGFloat = 5.0, offset: CGSize = CGSize.zero, opacity: Float = 0.2, colorAlpha: CGFloat = 0.1) -> ViewStyle {
        let shadowColor = UIColor(red: 39.0/255.0, green: 49.0/255.0, blue: 64.0/255.0, alpha: colorAlpha)
        let shadowStyle = ViewStyle.LayerStyle.ShadowStyle(color: shadowColor, radius: radius, offset: offset, opacity: opacity)
        let layerStyle = ViewStyle.LayerStyle(masksToBounds: false, cornerRadius: radius, borderStyle: nil, shadowStyle: shadowStyle)
        return ViewStyle(backgroundColor: nil, tintColor: nil, layerStyle: layerStyle)
    }
}

protocol ViewStyling {
    func style(_ style: ViewStyle)
}

extension UIView: ViewStyling {
    
    func style(_ style: ViewStyle) {
        if let backgroundColor = style.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let tintColor = style.tintColor {
            self.tintColor = tintColor
        }
        if let layerStyle = style.layerStyle {
            if let cornerRadius = layerStyle.cornerRadius {
                layer.cornerRadius = cornerRadius
            }
            if let masksToBounds = layerStyle.masksToBounds {
                layer.masksToBounds = masksToBounds
            }
            if let borderStyle = layerStyle.borderStyle {
                layer.borderColor = borderStyle.color.cgColor
                layer.borderWidth = borderStyle.width
            }
            
            if let shadowStyle = layerStyle.shadowStyle {

                layer.masksToBounds = false
                layer.shadowOffset = shadowStyle.offset
                layer.shadowRadius = shadowStyle.radius - 2
                layer.shadowOpacity = shadowStyle.opacity
                layer.shadowColor = shadowStyle.color.cgColor
                
                layer.shadowPath = UIBezierPath(roundedRect:bounds, cornerRadius:shadowStyle.radius).cgPath
                layer.rasterizationScale = UIScreen.main.scale
            }
        }
    }
}

////////////////////////////////////// Color Extension //////////////////////////////////////
extension UIColor {
    struct Neutral {
        static var mineShaft: UIColor       { return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1) }
        static var doveGray: UIColor        { return UIColor(red: 112.0/255.0, green: 112.0/255.0, blue: 112.0/255.0, alpha: 1) }
        static var silverChalice: UIColor   { return UIColor(red: 173.0/255.0, green: 173.0/255.0, blue: 173.0/255.0, alpha: 1) }
        static var iron: UIColor            { return UIColor(red: 214.0/255.0, green: 214.0/255.0, blue: 214.0/255.0, alpha: 1) }
        static var lilyWhite: UIColor       { return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1) }
        static var whiteSmoke: UIColor      { return UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1) }
        
        static var all: [UIColor] = [mineShaft, doveGray, silverChalice, iron, lilyWhite, whiteSmoke]
    }
    
    struct Primary {
        static var elephant: UIColor        { return UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 64.0/255.0, alpha: 1) }
        static var lightStateGray: UIColor  { return UIColor(red: 121.0/255.0, green: 133.0/255.0, blue: 151.0/255.0, alpha: 1) }
        static var cadetBlue: UIColor       { return UIColor(red: 179.0/255.0, green: 185.0/255.0, blue: 195.0/255.0, alpha: 1) }
        static var antiFlash: UIColor       { return UIColor(red: 241.0/255.0, green: 244.0/255.0, blue: 245.0/255.0, alpha: 1) }
        static var iceberg: UIColor         { return UIColor(red: 222.0/255.0, green: 244.0/255.0, blue: 246.0/255.0, alpha: 1) }
        static var viking: UIColor          { return UIColor(red: 89.0/255.0, green: 200.0/255.0, blue: 211.0/255.0, alpha: 1) }
        static var cornflowerBlue: UIColor  { return UIColor(red: 95.0/255.0, green: 151.0/255.0, blue: 251.0/255.0, alpha: 1) }
        
        static var all: [UIColor] = [elephant, lightStateGray, cadetBlue, antiFlash, iceberg, viking, cornflowerBlue]
    }
    
    struct Secondary {
        static var goldenTainoi: UIColor    { return UIColor(red: 254.0/255.0, green: 202.0/255.0, blue: 100.0/255.0, alpha: 1) }
        static var persianRed: UIColor      { return UIColor(red: 201.0/255.0, green: 43.0/255.0, blue: 50.0/255.0, alpha: 1) }
        static var sunglo: UIColor          { return UIColor(red: 217.0/255.0, green: 107.0/255.0, blue: 111.0/255.0, alpha: 1) }
        static var shilo: UIColor           { return UIColor(red: 233.0/255.0, green: 170.0/255.0, blue: 173.0/255.0, alpha: 1) }
        static var oasis: UIColor           { return UIColor(red: 254.0/255.0, green: 234.0/255.0, blue: 193.0/255.0, alpha: 1) }
        static var snowyMint: UIColor       { return UIColor(red: 221.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1) }
        static var fiejoa: UIColor          { return UIColor(red: 169.0/255.0, green: 217.0/255.0, blue: 108.0/255.0, alpha: 1) }
        
        static var all: [UIColor] = [goldenTainoi, persianRed, sunglo, shilo, oasis, snowyMint, fiejoa]
    }
    
    struct DarkThemeColors {
        static var lightBackgroundColor: UIColor { return UIColor.colorFromHexString("#1d1d1d") }
        static var buttonColor: UIColor { return UIColor.colorFromHexString("#1978fe") }
        static var darkBackgroundColor: UIColor { return UIColor.colorFromHexString("#262626") }
    }
    
    struct ChartColorsSet1 {
        static var first: UIColor       { return UIColor.colorFromHexString("#69a5b6") }
        static var second: UIColor      { return UIColor.colorFromHexString("#61b8c6") }
        static var third: UIColor       { return UIColor.colorFromHexString("#5ccad2") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#6dd1c8") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#7dd8bf") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#95e1bb") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#afe9b6") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#c7f1b3") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#dff9af") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#f3ffac") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }
    
    struct ChartColorsSet2 {
        static var first: UIColor       { return UIColor.colorFromHexString("#ed9268") }
        static var second: UIColor      { return UIColor.colorFromHexString("#f1985e") }
        static var third: UIColor       { return UIColor.colorFromHexString("#f5a25a") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#f9ad56") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#feb752") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#fec560") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#fdd575") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#fce58a") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#fbf39c") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#faffac") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }

    struct ChartColorsSet3 {
        static var first: UIColor       { return UIColor.colorFromHexString("#83a8d8") }
        static var second: UIColor      { return UIColor.colorFromHexString("#94b7da") }
        static var third: UIColor       { return UIColor.colorFromHexString("#9ec5dd") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#9bd0e4") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#99ddec") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#96e8f2") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#94f4f9") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#97feff") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#b6feff") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#d3ffff") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }
    
    struct ChartColorsSetVolcano {
        static var first: UIColor       { return UIColor.colorFromHexString("#fff2e8") }
        static var second: UIColor      { return UIColor.colorFromHexString("#ffd8bf") }
        static var third: UIColor       { return UIColor.colorFromHexString("#ffbb96") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#ff9c6e") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#ff7a45") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#fa541c") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#d4380d") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#ad2102") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#871400") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#610b00") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }
    
    struct ChartColorsSetSunsetOrange {
        static var first: UIColor       { return UIColor.colorFromHexString("#fff7e6") }
        static var second: UIColor      { return UIColor.colorFromHexString("#ffe7ba") }
        static var third: UIColor       { return UIColor.colorFromHexString("#ffd591") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#ffc069") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#ffa940") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#fa8c16") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#d46b08") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#ad4e00") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#873800") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#612500") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }

    struct ChartColorsCalendulaGold {
        static var first: UIColor       { return UIColor.colorFromHexString("#fffbe6") }
        static var second: UIColor      { return UIColor.colorFromHexString("#fff1b8") }
        static var third: UIColor       { return UIColor.colorFromHexString("#ffe58f") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#ffd666") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#ffc53d") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#faad14") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#d48806") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#ad6800") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#874d00") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#613400") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }
    
    struct ChartColorsSunriseYellow {
        static var first: UIColor       { return UIColor.colorFromHexString("#feffe6") }
        static var second: UIColor      { return UIColor.colorFromHexString("#ffffb8") }
        static var third: UIColor       { return UIColor.colorFromHexString("#fffb8f") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#fff566") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#ffec3d") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#fadb14") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#d4b106") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#ad8b00") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#876800") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#614700") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }

    struct ChartColorsLime {
        static var first: UIColor       { return UIColor.colorFromHexString("#fcffe6") }
        static var second: UIColor      { return UIColor.colorFromHexString("#f4ffb8") }
        static var third: UIColor       { return UIColor.colorFromHexString("#eaff8f") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#d3f261") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#bae637") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#a0d911") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#7cb305") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#5b8c00") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#3f6600") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#254000") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }

    struct ChartColorsCyan{
        static var first: UIColor       { return UIColor.colorFromHexString("#e6fffb") }
        static var second: UIColor      { return UIColor.colorFromHexString("#b5f5ec") }
        static var third: UIColor       { return UIColor.colorFromHexString("#87e8de") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#5cdbd3") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#36cfc9") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#13c2c2") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#08979c") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#006d75") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#00474f") }
        static var tenth: UIColor       { return UIColor.colorFromHexString("#002329") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth]
    }

    struct ChartColorsDarkSet1 {
        static var second: UIColor      { return UIColor.colorFromHexString("#BAE7FF") }
        static var third: UIColor       { return UIColor.colorFromHexString("#91D4FF") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#69C0FF") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#3FA9FF") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#1890FF") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#086DD9") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#0050B3") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#00398C") }
        
        static var all: [UIColor] = [second, third, fourth, fifth, sixth, seventh, eighth, ninth]
    }

    struct ChartColorsDarkSet2 {
        static var first: UIColor       { return UIColor.colorFromHexString("#f9f0ff") }
        static var second: UIColor      { return UIColor.colorFromHexString("#efdbff") }
        static var third: UIColor       { return UIColor.colorFromHexString("#d3adf7") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#b37feb") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#9254de") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#722ed1") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#531dab") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#391085") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#22075e") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth]
    }

    struct ChartColorsDarkSet3 {
        static var first: UIColor       { return UIColor.colorFromHexString("#fff0f6") }
        static var second: UIColor      { return UIColor.colorFromHexString("#ffd6e7") }
        static var third: UIColor       { return UIColor.colorFromHexString("#ffadd2") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#ff85c0") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#f759ab") }
        static var sixth: UIColor       { return UIColor.colorFromHexString("#eb2f96") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#eb2f96") }
        static var eighth: UIColor      { return UIColor.colorFromHexString("#9e1068") }
        static var ninth: UIColor       { return UIColor.colorFromHexString("#780650") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth]
    }

    struct MapTrackingColors {
        static var first: UIColor       { return UIColor.colorFromHexString("#59C8D3") }
        static var second: UIColor      { return UIColor.colorFromHexString("#F5A623") }
        static var third: UIColor       { return UIColor.colorFromHexString("#55ACEE") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#A9D96C") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#798597") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth]
    }
    
    struct MapTrackingUserPathColors {
        static var first: UIColor       { return UIColor.colorFromHexString("#47A0A8") }
        static var second: UIColor      { return UIColor.colorFromHexString("#C4841C") }
        static var third: UIColor       { return UIColor.colorFromHexString("#4489BE") }
        static var fourth: UIColor      { return UIColor.colorFromHexString("#87AD56") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#606A78") }
        
        static var all: [UIColor] = [first, second, third, fourth, fifth]
    }

    struct GaugeRangeColorsSet {
        static var first: UIColor       { return UIColor.colorFromHexString("#1700FF") }
        static var second: UIColor       { return UIColor.colorFromHexString("#3A7CCC") }
        static var third: UIColor      { return UIColor.colorFromHexString("#3DAABF") }
        static var fourth: UIColor       { return UIColor.colorFromHexString("#3BDBA6") }
        static var fifth: UIColor       { return UIColor.colorFromHexString("#21A579") }
        static var sixth: UIColor     { return UIColor.colorFromHexString("#02724D") }
        static var seventh: UIColor     { return UIColor.colorFromHexString("#00442E") }

        static var all: [UIColor] = [first, second, third, fourth, fifth, sixth, seventh]
    }

    struct BarChartRaceColorsSet {
        static var first: UIColor   { return UIColor.colorFromHexString("#813a8d") }
        static var second: UIColor  { return UIColor.colorFromHexString("#149fc5") }
        static var third: UIColor   { return UIColor.colorFromHexString("#fb291a") }
        static var fourth: UIColor  { return UIColor.colorFromHexString("#faaf0e") }
        static var fifth: UIColor   { return UIColor.colorFromHexString("#72b632") }

        static var all: [UIColor] = [first, second, third, fourth, fifth]
    }

}

////////////////////////////////////// Font Extension //////////////////////////////////////

extension UIFont {
    static func withSize(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch CurrentTheme {
        case .light:
            return UIFont.systemFont(ofSize: size, weight: weight)
        case .dark:
            return UIFont(name: exoFontNameFor(weight), size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
    
    static func exoFontNameFor(_ weight: UIFont.Weight) -> String {
        switch weight {
        case .regular:
            return "Exo2-Regular"
        case .medium:
            return "Exo2-Medium"
        case .semibold:
            return "Exo2-SemiBold"
        case .bold:
            return "Exo2-Bold"

        default:
            return "Exo2-Regular"

        }
    }
}

class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        layer.cornerRadius = 5
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5, height: 5)).cgPath
//        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

