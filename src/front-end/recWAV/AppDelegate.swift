//
//  AppDelegate.swift
//  NoisyGenX
//
//  Created by AnGie on 4/22/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import ShortCode
import VersionsTracker
import SideMenu

let iDontMindSingletons = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var customizedLaunchScreenView: UIView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDHNgFmRcnqNxkAnTd1PpbuCfWpuR1G0Qk")
        GMSPlacesClient.provideAPIKey("AIzaSyDHNgFmRcnqNxkAnTd1PpbuCfWpuR1G0Qk")
        
        if !iDontMindSingletons {
            VersionsTracker.initialize(trackAppVersion: true, trackOSVersion: true)
            switch VersionsTracker.sharedInstance.appVersion.changeState {
                case .installed:
                    /* generate a user id because app is launched for very first time */
                    let id = ShortCode.getCode(length: 15)
                    UserDefaults.standard.set(id, forKey: "user_id")
                    let audio_uploads_counter:Int = 1
                    UserDefaults.standard.set(audio_uploads_counter, forKey: "audio_upload_cnt")
            case .notChanged, .updated(previousVersion: _), .upgraded(previousVersion: _), .downgraded(previousVersion: _):
                break
            }
        }
        
        
        application.isStatusBarHidden = true
        
        // customized launch screen
        if let window = self.window {
            self.customizedLaunchScreenView = UIView(frame: window.bounds)
            self.customizedLaunchScreenView?.backgroundColor = UIColor.green
            
            self.window?.makeKeyAndVisible()
            self.window?.addSubview(self.customizedLaunchScreenView!)
            self.window?.bringSubview(toFront: self.customizedLaunchScreenView!)
            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseOut,
                                       animations: { () -> Void in
                                        self.customizedLaunchScreenView?.alpha = 0 },
                                       completion: { _ in
                                        self.customizedLaunchScreenView?.removeFromSuperview() })
        }
        
        let window = UIWindow()

        
        
        let mapViewNavigationController = UINavigationController(rootViewController: HomeViewController())
        mapViewNavigationController.navigationBar.barStyle = .black
        mapViewNavigationController.navigationBar.barTintColor = .blogBlue
        mapViewNavigationController.navigationBar.tintColor = .white
        mapViewNavigationController.navigationBar.isTranslucent = false
        mapViewNavigationController.navigationBar.shadowImage = UIImage()
        mapViewNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)

        window.rootViewController = mapViewNavigationController
        window.makeKeyAndVisible()
        
        self.window = window
    
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

