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
    private var upcomingNotifications: [ZmanNotification] {
        return notifications.sorted().filter { $0.notifyDate.timeIntervalSinceNow > 0 }
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    func doesAllowNotifications(completed: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    completed(true)
                } else {
                    completed(false)
                }
            }
        }
    }
    
    func getNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            let data = requests.flatMap { return $0.content.userInfo[ZmanNotification.userInfoKey] as? Data }
            self.notifications = data.flatMap { return try? JSONDecoder().decode(ZmanNotification.self, from: $0) }
            
        }
    }
    
    func add(_ notification: ZmanNotification, completed: (() -> Void)? = nil) {
        notificationCenter.add(notification.request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                } else {
                    self.notifications.append(notification)
                    completed?()
                }
            }
        }
    }
    
    func remove(_ notification: ZmanNotification) {
        let id = notification.id
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        notifications = upcomingNotifications.filter { $0 != notification }
    }
    
    func notification(forZman zman: Zman, location: Location, minutes: ZmanNotificationMinutes) -> ZmanNotification? {
        return upcomingNotifications.first { $0.zmanDate == zman.date && $0.locationTitle == location.title && $0.minutes == minutes }
    }
}
