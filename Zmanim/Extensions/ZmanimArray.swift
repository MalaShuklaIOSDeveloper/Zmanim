//
//  ZmanimArray.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

extension Sequence where Iterator.Element == Zman {
    func findNextZman(with date: Date, setZmanNext: Bool = false) -> Zman? {
        var nextZman: Zman?
        self.forEach { zman in
            if setZmanNext { zman.next = false }
            nextZman = nextZman == nil ? ((zman.date.timeIntervalSince(date).sign == .minus) ? nextZman : zman) : date.closestFutureDate(nextZman!.date, date2: zman.date)?.zman
        }
        if setZmanNext { nextZman?.next = true }
        return nextZman
    }
}
