//
//  ZmanimDataStore.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ZmanimDataStore {
    static let shared = ZmanimDataStore()
    
    var shacharis: [Zman]?
    var mincha: [Zman]?
    var maariv: [Zman]?
    var locations: [Location]?
    var localZmanim: [LocalZman]?
    
    private init() {}
    
}
