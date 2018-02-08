//
//  Tefillah.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type with values that represent a specific tefillah 📖.
enum Tefillah: String {
    case shacharis, mincha, maariv
    
    var title: String {
        switch self {
        case .shacharis :
            return "Shacharis"
        case .mincha :
            return "Mincha"
        case .maariv:
            return "Maariv"
        }
    }
    
    static let allTefillos: [Tefillah] = [.shacharis, .mincha, .maariv]
}
