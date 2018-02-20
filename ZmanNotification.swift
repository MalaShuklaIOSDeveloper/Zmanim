//
//  ZmanNotification.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/18/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UserNotifications

enum ZmanNotificationMinutes: Int, Codable {
    case five = 5, ten = 10, thirty = 30, oneHour = 60, twoHours = 120
    
    var displayValue: Int {
        switch self {
        case .oneHour, .twoHours:
            return rawValue/60
        default:
            return rawValue
        }
    }
    
    var title: String {
        switch self {
        case .oneHour:
            return "Hour"
        case .twoHours:
            return "Hours"
        default:
            return "Minutes"
        }
    }
    
    func date(before futureDate: Date) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: -rawValue, to: futureDate)
    }
    
    static var allMinutes: [ZmanNotificationMinutes] {
        return [.five, .ten, .thirty, .oneHour, .twoHours]
    }
}

/// A type that represent a notification 🔔 for a particular `Zman` and `Location`.
struct ZmanNotification: Codable {
    /// The tefillah.
    let tefillah: Tefillah
    /// The zman date.
    let zmanDate: Date
    /// The location title.
    let locationTitle: String
    /// The minutes proceeding to fire the notification.
    let minutes: ZmanNotificationMinutes
    /// A unique id for each created notification.
    let id: String
    static let userInfoKey = "ZmanNotification"
    
    init(zman: Zman, location: Location, minutes: ZmanNotificationMinutes) {
        self.tefillah = zman.tefillah
        self.zmanDate = zman.date
        self.locationTitle = location.title
        self.minutes = minutes
        self.id  = UUID().uuidString
    }
    
    /// The date object for the notification trigger date.
    var notifyDate: Date {
        return minutes.date(before: zmanDate)!
    }
}

extension ZmanNotification: Comparable {
    static func <(lhs: ZmanNotification, rhs: ZmanNotification) -> Bool {
        return lhs.notifyDate < rhs.notifyDate
    }
    
    static func ==(lhs: ZmanNotification, rhs: ZmanNotification) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ZmanNotification {
    var request: UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "\(tefillah.title)!"
        content.body = "\(minutes.displayValue) \(minutes.title.lowercased()) until \(tefillah.title.lowercased()) at \(locationTitle)."
        content.sound = UNNotificationSound.default()
        
        if let locationTitle = Location.Title(rawValue: locationTitle), let url = locationTitle.localImageURL {
            if let attachment = try? UNNotificationAttachment(identifier: url.absoluteString, url: url, options: nil) {
                content.attachments = [attachment]
            }
        }
        
        // Add `self` to user info for retrieving on subsequent launches.
        content.userInfo[ZmanNotification.userInfoKey] = try? JSONEncoder().encode(self)
        
        let triggerDateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: notifyDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
