//
//  CalendarCell.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    @IBOutlet var weekdayLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    
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
    
    func setTextWhite() {
        [dayLabel, weekdayLabel].forEach { $0?.textColor = .white }
    }
    
    func setTextBlack() {
        [dayLabel, weekdayLabel].forEach { $0?.textColor = .black }
    }
    
    func setDayStrawberry() {
        weekdayLabel.textColor = .black
        dayLabel.textColor = .strawberry
    }
}
