//
//  ZmanimViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

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
    
    var nextZman: Zman?
    
    var nextZmanIndexPath: IndexPath? {
        if let nextZman = nextZman, let zmanSection = zmanim?.index(of: nextZman) {
            return IndexPath(row: 0, section: zmanSection)
        }
        return nil
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
                self.setNextZman()
                // ...send to closure.
                completed(.success)
            }
        }
        // If the data store is empty or zmanim are old...
        else {
            // ...fetch new zmanim.
            ZmanimAPIClient.fetchZmanim(for: UserDataStore.shared.date) { result in
                switch result {
                case .success(let value):
                    if let zmanim = value[self.tefillah] {
                        if zmanim.isEmpty {
                            completed(.nothing)
                        } else {
                            self.zmanim = zmanim
                            self.setNextZman()
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
    
    func setNextZman() {
        if let zmanim = zmanim {
            let currentDate = Date()
            if let nextZmanDate = zmanim.map({ $0.date }).sorted().first(where: { $0.timeIntervalSince(currentDate) > 0 }) {
                nextZman = zman(for: nextZmanDate)
            }
        }
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
}
