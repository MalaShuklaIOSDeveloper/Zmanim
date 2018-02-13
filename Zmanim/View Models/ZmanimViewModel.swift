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
    
    init(data: ZmanimViewModelData) {
        self.tefillah = data.tefillah
    }
    
    func getZmanim(completed: @escaping ((GetZmanimResult) -> Void)) {
        // If there are zmanim cached in the data store and they are from today...
        if let tefillahZmanim = ZmanimDataStore.shared.zmanim(for: tefillah), let lastUpdatedDate = ZmanimDataStore.shared.lastZmanimUpdate, lastUpdatedDate.isToday {
            // ...set our zmanim to those zmanim.
            zmanim = tefillahZmanim
            completed(.success)
        }
        // If the data store is empty or zmanim are old...
        else {
            // ...fetch new zmanim.
            ZmanimAPIClient.fetchZmanim(for: UserDataStore.shared.date) { result in
                switch result {
                case .success(let value):
                    self.zmanim = value[self.tefillah]
                    completed(.success)
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
}
