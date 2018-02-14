//
//  ShnayimView.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class ShnayimView: UIView {
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
        layer.cornerRadius = 15
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 8
    }
}
