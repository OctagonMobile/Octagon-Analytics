//
//  Extensions.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import Foundation
import MBProgressHUD

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    static let withSeparator2DecimalPoint: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let withSeparatorIgnoringDecimal: NumberFormatter = {
        let formatter = Formatter.withSeparator
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

extension NSNumber {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
    
    var formattedWithSeparator2Decimal: String {
        return Formatter.withSeparator2DecimalPoint.string(for: self) ?? ""
    }

    var formattedWithSeparatorIgnoringDecimal: String {
        return Formatter.withSeparatorIgnoringDecimal.string(for: self) ?? ""
    }

}

extension UIFont {
    
    static func helveticaNeue(_ size: CGFloat) -> UIFont  {
        return UIFont(name: "HelveticaNeue", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func helveticaNeueBold(_ size: CGFloat) -> UIFont  {
        return UIFont(name: "HelveticaNeue-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return NSString(string: string).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: self],
            context: nil).size
    }
}

extension String {
    
    func formattedDate(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }

}

extension NSObject {
    struct NotificationName {
        static let dashboardRefreshNotification = "DashboardRefreshNotification"
    }

}

extension UIImage{
    static func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        // create a 1 by 1 pixel context
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
    
    func blurredImage() -> UIImage {
        
        guard let filter = CIFilter(name: "CIGaussianBlur")  else { return self }
        
        filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value: 8), forKey: kCIInputRadiusKey)
        let ctx = CIContext(options:nil)
        
        guard let outputImage = filter.outputImage else { return self }
        
        guard let inputImage = CIImage(image: self), let cgImage = ctx.createCGImage(outputImage, from: inputImage.extent) else { return self }

        return UIImage(cgImage: cgImage)
    }
}

public extension UIWindow {
    
    func capture() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)

        guard let context =  UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension CLLocationCoordinate2D {
    
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension Date {
    func getDateComponents(_ toDate: Date) -> DateComponents?  { 
        return Calendar.current.dateComponents([.second, .minute , .hour , .day,.month, .weekOfMonth,.year], from: self, to: toDate)
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}

extension UIColor {
    static func colorFromHexString (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension MBProgressHUD {
    private class func createHud(addedTo view: UIView, rotate: Bool = true) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        
        let width: CGFloat = isIPhone ? 60 : 100
        let customView = CustomHudView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        hud.customView = customView
        hud.mode = .customView
        hud.removeFromSuperViewOnHide = false
        hud.margin = 5.0
        // Equal width/height depending on whichever is larger
        hud.isSquare = true
        
        // Partially see-through bezel
        hud.bezelView.color = CurrentTheme.isDarkTheme ? UIColor.black : UIColor.white
        hud.bezelView.style = CurrentTheme.isDarkTheme ? .solidColor : .blur
        hud.bezelView.layer.cornerRadius = isIPhone ? 15.0 : 30.0
        
        // Dim background
        hud.backgroundView.color = .clear
        hud.backgroundView.style = .solidColor
        
        if rotate {
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0.0
            animation.speed = 0.5
            animation.toValue = 2.0 * Double.pi
            animation.duration = 1
            animation.repeatCount = HUGE
            animation.isRemovedOnCompletion = false
            hud.customView?.layer.add(animation, forKey: "rotationAnimation")
        }
        
        return hud
    }
    
    class func refreshing(addedTo view: UIView) -> MBProgressHUD {
        return createHud(addedTo: view, rotate: true)
    }
}
