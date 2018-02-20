//
//  ZmanimViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UserNotifications

struct ZmanimViewModelData {
    let tefillah: Tefillah
}

enum ZmanCellIdentifier: String {
    case zmanCell
}

enum GetZmanimResult {
    case success
    case nothing
    case error
}

class ZmanimViewModel {
    /// The tefillah to display zmanim for.
    var tefillah: Tefillah!
    
    /// The zmanim to display.
    private var zmanim: [Zman]?
    
    let zmanCellIdentifier: ZmanCellIdentifier = .zmanCell
    
    var numberOfSections: Int {
        return zmanim?.count ?? 0
    }
    
    var nextZman: Zman? {
        return ZmanimDataStore.shared.nextZman(for: Date())
    }
    
    var nextZmanIndexPath: IndexPath? {
        if let nextZman = nextZman, let zmanSection = zmanim?.index(of: nextZman) {
            return IndexPath(row: 0, section: zmanSection)
        }
        return nil
    }
    
    var selectedDate: Date {
        return UserDataStore.shared.date
    }
    
    var selectedNotifyIndexPath: IndexPath?
    
    var selectedNotificationMinutes: [ZmanNotificationMinutes] {
        if let indexPath = selectedNotifyIndexPath {
            return notificationMinutes(for: indexPath)
        }
        return []
    }
    
    init(data: ZmanimViewModelData) {
        self.tefillah = data.tefillah
    }
    
    func getZmanim(completed: @escaping ((GetZmanimResult) -> Void)) {
        // If there are zmanim cached in the data store and they are from today...
        if let tefillahZmanim = ZmanimDataStore.shared.zmanim(for: tefillah), let lastUpdatedDate = ZmanimDataStore.shared.lastZmanimUpdate, lastUpdatedDate.isToday {
            // If there are no zmanim...
            if tefillahZmanim.isEmpty {
                // ...send to closure.
                completed(.nothing)
            }
            // If there are zmanim...
            else {
                // ...set our zmanim to those zmanim...
                zmanim = tefillahZmanim
                // ...send to closure.
                completed(.success)
            }
        }
        // If the data store is empty or zmanim are old...
        else {
            // ...fetch new zmanim.
            ZmanimAPIClient.fetchZmanim(for: selectedDate) { result in
                switch result {
                case .success(let value):
                    if let zmanim = value[self.tefillah] {
                        if zmanim.isEmpty {
                            completed(.nothing)
                        } else {
                            self.zmanim = zmanim
                            completed(.success)
                        }
                    }
                case .failure(let error):
                    print(error)
                    completed(.error)
                }
            }
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        return zmanim?[section].locations.count ?? 0
    }
    
    func zman(for index: Int) -> Zman? {
        return zmanim?[index]
    }
    
    func zman(for date: Date) -> Zman? {
        if let zmanim = zmanim {
            for zman in zmanim {
                if zman.date == date {
                    return zman
                }
            }
        }
        return nil
    }
    
    func notificationMinutes(for indexPath: IndexPath) -> [ZmanNotificationMinutes] {
        if let zmanim = zmanim {
            let zman = zmanim[indexPath.section]
            return ZmanNotificationMinutes.allMinutes.filter { $0.date(before: zman.date)!.timeIntervalSinceNow > 0 }
        }
        return []
    }
    
    func notification(forIndexPath indexPath: IndexPath, minutes: ZmanNotificationMinutes) -> ZmanNotification? {
        if let zmanim = zmanim {
            let zman = zmanim[indexPath.section]
            let location = zman.locations[indexPath.row]
            return UserDataStore.shared.notification(forZman: zman, location: location, minutes: minutes)
        }
        return nil
    }
    
    func addNotification(for minutes: ZmanNotificationMinutes, completed: (() -> Void)? = nil) {
        if let indexPath = selectedNotifyIndexPath, let zmanim = zmanim {
            let zman = zmanim[indexPath.section]
            let location = zman.locations[indexPath.row]
            let notification = ZmanNotification(zman: zman, location: location, minutes: minutes)
            UserDataStore.shared.add(notification, completed: completed)
        }
    }
    
    func removeNotification(for minutes: ZmanNotificationMinutes) {
        if let indexPath = selectedNotifyIndexPath {
            if let notification = notification(forIndexPath: indexPath, minutes: minutes) {
                UserDataStore.shared.remove(notification)
            }
        }
    }
    
    func isMinutesSelected(at index: Int) -> Bool {
        if let indexPath = selectedNotifyIndexPath {
            if index < selectedNotificationMinutes.count {
                let minutes = selectedNotificationMinutes[index]
                return notification(forIndexPath: indexPath, minutes: minutes) != nil
            }
        }
        return false
    }
    
    func isAnyMinutesSelected(at indexPath: IndexPath) -> Bool {
        for minutes in ZmanNotificationMinutes.allMinutes {
            if notification(forIndexPath: indexPath, minutes: minutes) != nil {
                return true
            }
        }
        return false
    }
}
