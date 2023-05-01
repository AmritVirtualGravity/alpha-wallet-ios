// Copyright © 2022 Stormbird PTE. LTD.

import UIKit
import SDWebImageSVGCoder


let deploymentMode: DeploymentMode = {
#if DEV
    return .dev
#endif
    
#if UAT
    return .uat
#endif
    
#if LIVE
    return .live
#endif
    return .dev //default
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var appCoordinator: AppCoordinator!
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        printChangedViewControllerEveryTime()
        applyTheSystemAppearance()
        do {
            
            // register coder, on AppDelegate
            let SVGCoder = SDImageSVGCoder.shared
            SDImageCodersManager.shared.addCoder(SVGCoder)
            appCoordinator = try AppCoordinator.create()
            
            appCoordinator.start(launchOptions: launchOptions)
            
        } catch {
            //no-op
        }
        
        return true
    }
    
    private func applyTheSystemAppearance() {
        let userDefault = UserDefaults.standard
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        if (userDefault.bool(forKey: "DarkModeOn") == true) {
//
//            window?.overrideUserInterfaceStyle = .dark
////            userDefault.set(false, forKey: "DarkModeOn")
//        } else {
//            window?.overrideUserInterfaceStyle = .light
////            userDefault.set(true, forKey: "DarkModeOn")
//        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let window =  UIApplication.shared.windows.first(where: { $0.isKeyWindow })
             switch  (userDefault.bool(forKey: "DarkModeOn")) {
             case true: window?.overrideUserInterfaceStyle  = .dark
             case false: window?.overrideUserInterfaceStyle = .light
             }
         }

  
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        appCoordinator.applicationPerformActionFor(shortcutItem, completionHandler: completionHandler)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        appCoordinator.applicationWillResignActive()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        appCoordinator.applicationDidBecomeActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        appCoordinator.applicationDidEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        appCoordinator.applicationWillEnterForeground()
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        return appCoordinator.applicationShouldAllowExtensionPointIdentifier(extensionPointIdentifier)
    }
    
    // URI scheme links and AirDrop
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return appCoordinator.applicationOpenUrl(url, options: options)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return appCoordinator.applicationContinueUserActivity(userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //no op
    }
}



// MARK: Print Current VC
extension AppDelegate {
    func printChangedViewControllerEveryTime(previousViewController: String = "") {
        let currentViewController = String(describing: type(of: UIApplication.topViewController() ?? UIViewController()))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if (currentViewController != previousViewController) {
                print("\n---------------- \(currentViewController.replacingOccurrences(of: "ViewController", with: "")) ------------------- ")
            }
            self.printChangedViewControllerEveryTime(previousViewController: currentViewController)
        }
    }
    
}
