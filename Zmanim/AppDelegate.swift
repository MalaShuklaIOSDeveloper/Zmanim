//
//  AppDelegate.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var handleNotificationWhenActive: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set as notification center delegate.
        UNUserNotificationCenter.current().delegate = self
        
        // Request authorization for user local notifications.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
        
        // Get all pending notifications and store them.
        UserDataStore.shared.getNotifications()
        
        // Set data store as API observer to keep data up to date.
        ZmanimDataStore.shared.setAsZmanimAPIObserver()
        
        // Set the navigation bar to white application wide.
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        handleNotificationWhenActive?()
        handleNotificationWhenActive = nil
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let data = response.notification.request.content.userInfo[ZmanNotification.userInfoKey] as? Data, let zmanNotification = try? JSONDecoder().decode(ZmanNotification.self, from: data), let navigationViewController = window?.rootViewController as? UINavigationController {
            if let homeViewController = navigationViewController.viewControllers.first as? HomeViewController {
                handleNotificationWhenActive = {
                    if navigationViewController.topViewController != homeViewController {
                        navigationViewController.popToRootViewController(animated: false)
                    }
                    homeViewController.viewModelData.notification = zmanNotification
                    homeViewController.selectInitialIndexPath()
                }
            }
        }
        completionHandler()
    }
}
