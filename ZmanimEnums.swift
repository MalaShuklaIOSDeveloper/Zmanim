//
//  ZmanimEnums.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation

enum Tefillah: String {
    case shacharis, mincha, maariv
    
    var title: String {
        switch self {
        case .shacharis :
            return Constants.Shacharis
        case .mincha :
            return Constants.Mincha
        case .maariv:
            return Constants.Maariv
        }
    }
}
