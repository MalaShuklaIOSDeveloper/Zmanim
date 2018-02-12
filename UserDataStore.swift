//
//  UserDataStore.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A data store for user 👨🏻 data.
class UserDataStore {
    let shared = UserDataStore()
    var date = Date()
    
    private init() {}
}
