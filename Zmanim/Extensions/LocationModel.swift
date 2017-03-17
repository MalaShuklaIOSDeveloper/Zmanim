//
//  LocationModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

extension Location {
    var nextZman: Zman? {
        return zmanim.findNextZman(with: ZmanimDataSource.dataSource.date)
    }
}
