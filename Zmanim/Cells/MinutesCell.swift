//
//  MinutesCell.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/19/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class MinutesCell: UICollectionViewCell {
    override var isSelected: Bool {
        get {
            return super.isSelected
        } set {
            super.isSelected = newValue
            if isSelected {
                setSelectedColors()
            } else {
                setRegularColors()
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
        setRegularColors()
    }
    
    private func setRegularColors() {
        backgroundColor = .white
        [minutesLabel, titleLabel].forEach { $0?.textColor = .black }
    }
    
    private func setSelectedColors() {
        backgroundColor = .blueberry
        [minutesLabel, titleLabel].forEach { $0?.textColor = .white }
    }
}
