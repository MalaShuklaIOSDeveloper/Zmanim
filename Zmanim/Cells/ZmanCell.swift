//
//  ZmanCell.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ZmanTableViewCell: UITableViewCell {
    // MARK: Properties
    var tefillah: Tefillah!
    var zman: Zman!
    var location: Location!
    
    // MARK: Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var locationLabel: UILabel!
}
