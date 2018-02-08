//
//  AppDelegate.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ZmanimDataStore.shared.setAsZmanimAPIObserver()
        
        // Set the navigation bar to white application wide.
        UINavigationBar.appearance().barTintColor = UIColor.white
        
        return true
    }
 }
