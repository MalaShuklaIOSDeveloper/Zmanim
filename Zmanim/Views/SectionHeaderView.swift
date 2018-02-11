//
//  SectionHeaderView.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

class SectionTitleHeaderView: UIView {
    let headerLabel = UILabel()
    
    init(title: String, titleColor: UIColor, backgroundColor: UIColor) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = backgroundColor
        
        headerLabel.text = title
        headerLabel.textColor = titleColor
        headerLabel.font = UIFont.boldSystemFont(ofSize: headerLabel.font.pointSize)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addConstraints([
            leftAnchor.constraint(equalTo: headerLabel.leftAnchor, constant: 20),
            topAnchor.constraint(equalTo: headerLabel.topAnchor),
            rightAnchor.constraint(equalTo: headerLabel.rightAnchor),
            bottomAnchor.constraint(equalTo: headerLabel.bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
