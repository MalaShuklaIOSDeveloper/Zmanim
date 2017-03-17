//
//  LocalZmanimViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol LocalZmanimTableViewControllerDataSource {
    var localZmanim: [LocalZman]? { get }
}

class LocalZmanimViewModel {
    let dataSource: LocalZmanimTableViewControllerDataSource
    
    init(dataSource: LocalZmanimTableViewControllerDataSource) {
        self.dataSource = dataSource
    }
    
    func findNextLocalZman() -> LocalZman? {
        var nextLocalZman: LocalZman?
        if let dataSourceLocalZmanim = dataSource.localZmanim {
            for localZman in dataSourceLocalZmanim {
                localZman.next = false
                nextLocalZman = (nextLocalZman == nil ? (((localZman.date as NSDate).timeIntervalSince(NSDate() as Date).sign == .minus) ? nil : localZman) : Date().closestFutureDate(nextLocalZman!.date, date2: localZman.date)?.localZman)
            }
        }
        nextLocalZman?.next = true
        return nextLocalZman
    }
}
