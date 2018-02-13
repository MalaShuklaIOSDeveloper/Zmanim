//
//  HomeViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HomeItemKey {
    case tefillah, zmanim, more
}

enum HomeCellIdentifier: String {
    case itemCell
}

protocol HomeItem {
    var key: HomeItemKey { get }
    var title: String { get }
    var cellIdentifier: HomeCellIdentifier { get }
}

class HomeViewModel {
    let items: [HomeItem] = [
        TefillahHomeItem(tefillah: .shacharis),
        TefillahHomeItem(tefillah: .mincha),
        TefillahHomeItem(tefillah: .maariv),
        ZmanimHomeItem(),
        MoreHomeItem()
    ]
    
    /// The date for zmanim.
    var selectedDate: Date {
        get {
            return UserDataStore.shared.date
        } set {
            UserDataStore.shared.date = newValue
        }
    }
    
    /// An array of dates for the coming week including today.
    var thisWeekDates: [Date] {
        var dates = [Date()]
        for days in 1...6 {
            if let date = Calendar.current.date(byAdding: .day, value: days, to: Date()) {
                dates.append(date)
            }
        }
        return dates
    }
    
    func getZmanim() {
        ZmanimDataStore.shared.clearData()
        ZmanimAPIClient.fetchZmanim(for: selectedDate)
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        return items.count
    }
}

struct TefillahHomeItem: HomeItem {
    let key: HomeItemKey = .tefillah
    let tefillah: Tefillah
    let cellIdentifier: HomeCellIdentifier = .itemCell
    
    var title: String {
        return tefillah.title
    }
}

struct ZmanimHomeItem: HomeItem {
    let key: HomeItemKey = .zmanim
    let cellIdentifier: HomeCellIdentifier = .itemCell
    
    var title: String {
        return "Zmanim"
    }
}

struct MoreHomeItem: HomeItem {
    let key: HomeItemKey = .more
    let cellIdentifier: HomeCellIdentifier = .itemCell
    
    var title: String {
        return "More"
    }
}
