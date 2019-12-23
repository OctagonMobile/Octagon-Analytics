//
//  Extensions.swift
//  KibanaGo
//
//  Created by Rameez on 11/29/17.
//  Copyright © 2017 MyCompany. All rights reserved.
//

import Foundation

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
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
