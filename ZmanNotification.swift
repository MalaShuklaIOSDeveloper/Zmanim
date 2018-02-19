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
    let minutes: ZmanNotificationMinutes
    let id: String = UUID().uuidString
}

enum ZmanNotificationMinutes: Int {
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
    
    static var allMinutes: [ZmanNotificationMinutes] {
        return [.five, .ten, .thirty, .oneHour, .twoHours]
    }
}

extension ZmanNotification {
    var request: UNNotificationRequest? {
        if let notifyDate = Calendar.current.date(byAdding: .minute, value: -minutes.rawValue, to: zman.date) {
            let content = UNMutableNotificationContent()
            content.title = "\(zman.tefillah.title)!"
            content.body = "\(minutes.displayValue) \(minutes.title.lowercased()) until \(zman.tefillah.title.lowercased()) at \(location.title)."
            content.sound = UNNotificationSound.default()
            
            if let locationTitle = Location.Title(rawValue: location.title), let url = locationTitle.localImageURL {
                if let attachment = try? UNNotificationAttachment(identifier: url.absoluteString, url: url, options: nil) {
                    content.attachments = [attachment]
                }
            }
            
            let triggerDateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: notifyDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        }
        return nil
    }
}
