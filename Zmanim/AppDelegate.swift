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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set data store as API observer to keep data up to date.
        ZmanimDataStore.shared.setAsZmanimAPIObserver()
        
        // Request authorization for user local notifications.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
        
        // Get all pending notifications and store them.
        UserDataStore.shared.getNotifications()
        
        // Set the navigation bar to white application wide.
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        return true
    }
 }
