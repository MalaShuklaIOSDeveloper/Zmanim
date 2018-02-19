//
//  ZmanNotification.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UserNotifications

struct ZmanNotification {
    let zman: Zman
    let location: Location
    var minutesBefore: Int
    let id: String = UUID().uuidString
}

extension ZmanNotification {
    var request: UNNotificationRequest? {
        if let notifyDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: zman.date) {
            let content = UNMutableNotificationContent()
            content.title = "\(minutesBefore) until \(zman.tefillah.title) at \(location.title)!"
            
            let triggerDateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: notifyDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        }
        return nil
    }
}
