//
//  LocalZmanimViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

enum LocalZmanCellIdentifier: String {
    case localZmanCell
}

enum GetLocalZmanimResult {
    case success
    case error
}

class LocalZmanimViewModel {
    private var localZmanim: [LocalZman]?
    
    let localZmanCellIdentifier: LocalZmanCellIdentifier = .localZmanCell
    
    var numberOfSections: Int {
        return 1
    }
    
    func getLocalZmanim(completed: @escaping ((GetLocalZmanimResult) -> Void)) {
        // If there are local zmanim cached in the data store and they are from today...
        if let localZmanim = ZmanimDataStore.shared.localZmanim, let lastUpdatedDate = ZmanimDataStore.shared.lastLocalZmanimUpdate, lastUpdatedDate.isToday {
            // ...set our local zmanim to those local zmanim.
            self.localZmanim = localZmanim
            completed(.success)
        }
        // If the data store is empty or local zmanim are old...
        else {
            // ...fetch new local zmanim.
            ZmanimAPIClient.fetchLocalZmanim(for: UserDataStore.shared.date) { result in
                switch result {
                case .success(let value):
                    self.localZmanim = value
                    completed(.success)
                case .failure(let error):
                    print(error)
                    completed(.error)
                }
            }
        }
    }
    
    func numberOfRows(in section: Int) -> Int {
        return localZmanim?.count ?? 0
    }
    
    func localZman(for index: Int) -> LocalZman? {
        return localZmanim?[index]
    }
}
