//
//  HomeViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum HomeItemKey {
    case tefillah, more
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
        MoreHomeItem()
    ]
    
    func getZmanim() {
        ZmanimAPIClient.fetchZmanim(for: Date())
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

struct MoreHomeItem: HomeItem {
    let key: HomeItemKey = .tefillah
    let cellIdentifier: HomeCellIdentifier = .itemCell
    
    var title: String {
        return "More"
    }
}
