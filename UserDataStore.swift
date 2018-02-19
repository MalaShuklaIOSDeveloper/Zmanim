//
//  UserDataStore.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UserNotifications

/// A data store for user 👨🏻 data.
class UserDataStore {
    static let shared = UserDataStore()
    /// The date used to get zmanim.
    var date = Date()
    /// The notifications associated with the user.
    private var notifications = [ZmanNotification]()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    func add(_ notification: ZmanNotification) {
        if let request = notification.request {
            notificationCenter.add(request) { error in
                if let error = error {
                    print(error)
                } else {
                    self.notifications.append(notification)
                }
            }
        }
    }
    
    func notification(forZman zman: Zman, location: Location) -> ZmanNotification? {
        return notifications.first { $0.zman == zman && $0.location == location }
    }
}
