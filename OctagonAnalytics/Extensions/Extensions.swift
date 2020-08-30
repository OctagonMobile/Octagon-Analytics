//
//  Extensions.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import Foundation
import MBProgressHUD
import OctagonAnalyticsService
import Eureka

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
    class func topViewController(controller: UIViewController? = UIApplication.appKeyWindow?.rootViewController) -> UIViewController? {
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
    
    static var appKeyWindow: UIWindow? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
}

extension CLLocationCoordinate2D {
    
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

}

extension UIView {
    func blink(_ duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, alpha: CGFloat = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.alpha = alpha
        })
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
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UITabBarController {
    func setTabBarVisible(visible:Bool, duration: TimeInterval, animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? -height : height)

        // animation
        UIViewPropertyAnimator(duration: duration, curve: .linear) {
            _ = self.tabBar.frame.offsetBy(dx:0, dy:offsetY)
            self.view.frame = CGRect(x:0,y:0,width: self.view.frame.width, height: self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }.startAnimation()
    }

    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < UIScreen.main.bounds.height
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

extension NSNumber {
    var isNumberFractional: Bool {
        let str = self.stringValue
        return (str.split(separator: ".").count > 1)
    }
}

extension Double {
    var isInteger: Bool {
        return floor(self) == self
    }
}

extension String {
    var isBool: Bool {
        return self == "false" || self == "true"
    }
}

struct BoolAsString {
   static let true_ = "true"
   static let false_ = "false"
}
extension Float {
    func round(to places: Int) -> String {
        return String(format: "%0.\(places)f", self)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: minX + width / 2, y: minY + height / 2)
    }
}

extension URL {

    func URLByAppendingQueryParameters(_ params: [String: String]?) -> URL? {
        guard let parameters = params,
          var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }

        var mutableQueryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        mutableQueryItems.append(contentsOf: parameters.compactMap({ URLQueryItem(name: $0, value: $1)}))

        urlComponents.queryItems = mutableQueryItems
        return urlComponents.url
    }
}

extension OAServiceError {
    var asNSError: NSError {
        return NSError(domain: AppName, code: 1001, userInfo: [NSLocalizedDescriptionKey: self.errorDescription])
    }
}

extension Double {
    func round(to places: Int) -> Double {
           let divisor = pow(10.0, Double(places))
           return (self * divisor).rounded() / divisor
    }
    
    var formatToKandM: String{
        let num = self
        let thousandNum = num/1000
        let millionNum = num/1000000
        if self >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))K")
            }
            return("\(thousandNum.round(to:1))K")
        }
        if self > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))K")
            }
            return ("\(millionNum.round(to:1))M")
        }
        else{
            if(floor(num) == num){
                return ("\(Int(num))")
            }
            return ("\(num)")
        }

    }
}


protocol Orderable {
    associatedtype OrderElement: Equatable
    var orderElement: OrderElement { get }
}
extension Array where Element: Orderable {

    func reorder(basedOn preferredOrder: [Element.OrderElement]) -> [Element] {
        sorted {
            guard let first = preferredOrder.firstIndex(of: $0.orderElement) else {
                return false
            }

            guard let second = preferredOrder.firstIndex(of: $1.orderElement) else {
                return true
            }

            return first < second
        }
    }
}

extension SegmentedCell {
    func setControlWidth(_ width: CGFloat) {
        guard let segmentedControl = segmentedControl else { return }
        let widthConstraint = NSLayoutConstraint(
            item: segmentedControl,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: width
        )
        
        let centerConstraint = NSLayoutConstraint(
            item: segmentedControl,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        addConstraint(centerConstraint)

        addConstraints([widthConstraint, centerConstraint])
    }
}
