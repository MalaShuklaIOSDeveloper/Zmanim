//
//  ZmanimDataStore.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

/// A data store for zmanim data 📦.
class ZmanimDataStore {
    static let shared = ZmanimDataStore()
    let id = UUID().uuidString
    
    var shacharis: [Zman]?
    var mincha: [Zman]?
    var maariv: [Zman]?
    var locations: [Location]?
    var localZmanim: [LocalZman]?
    
    /// An array of all the zmanim in `shacharis`, `mincha` and `maariv`.
    var allZmanim: [Zman]? {
        if let shacharis = shacharis, let mincha = mincha, let maariv = maariv {
            return shacharis + mincha + maariv
        }
        return nil
    }
    
    /// Last time `shacharis`, `mincha`, `maariv` was updated.
    var lastZmanimUpdate: Date?
    
    /// Last time `locations` was updates.
    var lastLocationsUpdate: Date?
    
    /// Last time `localZmanim` was updates.
    var lastLocalZmanimUpdate: Date?
    
    lazy var zmanimDidChange: ((Zmanim) -> Void) = { zmanim in
        for tefillah in Tefillah.allTefillos {
            if let tefillahZmanim = zmanim[tefillah] {
                switch tefillah {
                case .shacharis:
                    self.shacharis = tefillahZmanim
                case .mincha:
                    self.mincha = tefillahZmanim
                case .maariv:
                    self.maariv = tefillahZmanim
                }
            }
        }
        
        // Set last updated zmanim date to current date.
        self.lastZmanimUpdate = Date()
    }
    
    lazy var locationsDidChange: (([Location]) -> Void) = { locations in
        self.locations = locations
        
        // Set last updated locations date to current date.
        self.lastLocationsUpdate = Date()
    }
    
    lazy var localZmanimDidChange: (([LocalZman]) -> Void) = { localZmanim in
        self.localZmanim = localZmanim
        
        // Set last updated locations date to current date.
        self.lastLocalZmanimUpdate = Date()
    }
    
    private init() {}
    
    func setAsZmanimAPIObserver() {
        ZmanimAPIClient.addObserver(self)
    }
    
    func zmanim(for tefillah: Tefillah) -> [Zman]? {
        switch tefillah {
        case .shacharis:
            return shacharis
        case .mincha:
            return mincha
        case .maariv:
            return maariv
        }
    }
    
    func nextZman(for date: Date) -> Zman? {
        // Searches for next zman that date is a positive time interval from `date`.
        if let nextZman = allZmanim?.sorted().first(where: { $0.date.timeIntervalSince(date) > 0 }) {
            return nextZman
        }
        return nil
    }
    
    func clearData() {
        shacharis = nil
        mincha = nil
        maariv = nil
        locations = nil
        localZmanim = nil
    }
}

extension ZmanimDataStore: ZmanimAPIObserver {}
