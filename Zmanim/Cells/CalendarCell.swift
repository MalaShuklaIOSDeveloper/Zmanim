//
//  CalendarCell.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/11/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var weekdayLabel: UILabel!
    
    func setTextWhite() {
        [monthLabel, dayLabel, weekdayLabel].forEach { $0?.textColor = .white }
    }
    
    func setTextBlack() {
        [monthLabel, dayLabel, weekdayLabel].forEach { $0?.textColor = .black }
    }
    
    func setDayStrawberry() {
        [monthLabel, weekdayLabel].forEach { $0?.textColor = .black }
        dayLabel.textColor = .strawberry
    }
}
