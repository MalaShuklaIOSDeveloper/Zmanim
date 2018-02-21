//
//  AppDelegate.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    /// The notification the app is launching from.
    var notification: ZmanNotification?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set as notification center delegate.
        UNUserNotificationCenter.current().delegate = self
        
        // Request authorization for user local notifications.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        
        // Get all pending notifications and store them.
        UserDataStore.shared.getNotifications()
        
        // Set api client to listen for base url changes.
        ZmanimAPIClient.startBaseURLValueChangeObserver()
        
        // Set data store as API observer to keep data up to date.
        ZmanimDataStore.shared.setAsZmanimAPIObserver()
        
        // Set the navigation bar to white application wide.
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Perform actions if launching from notification.
        if let notification = self.notification,
            let navigationViewController = window?.rootViewController as? UINavigationController,
            let homeViewController = navigationViewController.viewControllers.first as? HomeViewController {
            // If the navigation controller is not currently showing home...
            if navigationViewController.topViewController != homeViewController {
                // ...pop back to home.
                navigationViewController.popToRootViewController(animated: false)
            }
            homeViewController.viewModelData.notification = notification
            homeViewController.selectInitialIndexPath()
            self.notification = nil
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Set notification if launching from one.
        if let data = response.notification.request.content.userInfo[ZmanNotification.userInfoKey] as? Data,
            let zmanNotification = try? JSONDecoder().decode(ZmanNotification.self, from: data) {
            notification = zmanNotification
        }
        completionHandler()
    }
}
