//
//  ZmanCell.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ZmanCell: UITableViewCell {
    var didTapNotify: ((ZmanCell) -> Void)?
    
    @IBOutlet weak var locationLabel: UILabel!

    @IBAction func didTapNotify(_ sender: UIButton) {
        didTapNotify?(self)
    }
}
