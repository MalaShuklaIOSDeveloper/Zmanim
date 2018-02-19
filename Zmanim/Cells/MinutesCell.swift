//
//  MinutesCell.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class MinutesCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        layer.masksToBounds = false
        layer.cornerRadius = 15
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize.zero
    }
}
