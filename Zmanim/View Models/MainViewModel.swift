//
//  MainViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation

protocol MainTableViewControllerDataSource {
    var zmanim: [Zman]? { get }
    var date: Date { get }
}

class MainViewModel {
    let dataSource: MainTableViewControllerDataSource
    
    init(dataSource: MainTableViewControllerDataSource) {
        self.dataSource = dataSource
    }
    
    func findNextZman() -> Zman? {
        if let dataSourceZmanim = dataSource.zmanim {
            return dataSourceZmanim.findNextZman(with: dataSource.date)
        }
        return nil
    }
}
