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
    }
    
    lazy var locationsDidChange: (([Location]) -> Void) = { locations in
        self.locations = locations
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
}

extension ZmanimDataStore: ZmanimAPIObserver {}
