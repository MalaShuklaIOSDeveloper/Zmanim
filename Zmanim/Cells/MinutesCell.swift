//
//  MinutesCell.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class MinutesCell: UICollectionViewCell {
    var isColorsInverted = false {
        didSet {
            if isColorsInverted {
                invertColors()
            } else {
                regularColors()
            }
        }
    }
    
    @IBOutlet var minutesLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    
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
    
    private func regularColors() {
        backgroundColor = .blueberry
        [minutesLabel, titleLabel].forEach { $0?.textColor = .white }
    }
    
    private func invertColors() {
        backgroundColor = .blueberry
        [minutesLabel, titleLabel].forEach { $0?.textColor = .white }
    }
}
