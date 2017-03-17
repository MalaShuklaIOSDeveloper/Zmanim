//
//  ZmanimViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol ZmanimTableViewControllerDataSource {
    var zmanim: [Zman]? { get }
    var date: Date { get }
}

class ZmanimViewModel {
    let dataSource: ZmanimTableViewControllerDataSource
    
    init(dataSource: ZmanimTableViewControllerDataSource) {
        self.dataSource = dataSource
    }
    
    func findNextZman() -> Zman? {
        if let dataSourceZmanim = dataSource.zmanim {
            return dataSourceZmanim.findNextZman(with: dataSource.date, setZmanNext: true)
        }
        return nil
    }
}
