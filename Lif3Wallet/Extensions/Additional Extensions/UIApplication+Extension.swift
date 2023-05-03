//
//  UIApplication+Extension.swift
//  Salon Customer
//
//  Created by Amrit Duwal on 2/15/21.
//

import UIKit

extension UIApplication {
    
    class func topViewController() -> UIViewController? {
        // for ios 13+
        
        #warning("UIWindow.rootViewController must be used from main thread only")
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first // 
        var topVC = keyWindow?.rootViewController
        
        while true {
            if let presented = topVC?.presentedViewController {
                topVC = presented
            } else if let nav = topVC as? UINavigationController {
                topVC = nav.visibleViewController
            } else if let tab = topVC as? UITabBarController {
                topVC = tab.selectedViewController
            } else {
                break
            }
        }
        return topVC
    }
    
    
    class func removeAllNotification()  { // not checked yet
            // for ios 13+
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let topVC = keyWindow?.rootViewController
        for vc in topVC?.children ?? [] {
            NotificationCenter.default.removeObserver(vc)
        }
    }
    
}



extension UIApplication {
    
    var customKeyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
