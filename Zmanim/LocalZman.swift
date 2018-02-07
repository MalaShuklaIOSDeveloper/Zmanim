//
//  LocalZman.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a local zmanim time 🕰.
class LocalZman {
    let title: String
    let date: Date
    var next: Bool
    
    init(title: String, date: Date, next: Bool = false) {
        self.title = title
        self.date = date
        self.next = next
    }
}
