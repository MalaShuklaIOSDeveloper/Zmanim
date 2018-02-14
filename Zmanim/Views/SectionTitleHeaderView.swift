//
//  SectionTitleHeaderView.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

class SectionTitleHeaderView: UIView {
    var title: String? {
        didSet {
            update()
        }
    }
    
    var titleSize: CGFloat = 20 {
        didSet {
            update()
        }
    }
    
    var titleColor: UIColor = .black {
        didSet {
            update()
        }
    }
    
    private let headerLabel = UILabel()
    
    init(title: String, titleSize: CGFloat = 20, titleColor: UIColor = .black) {
        self.title = title
        self.titleColor = titleColor
        self.titleColor = titleColor
        
        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            headerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.rightAnchor.constraint(equalTo: rightAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setup() {
        backgroundColor = .snow
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerLabel)
        update()
    }
    
    func update() {
        headerLabel.text = title
        headerLabel.textColor = titleColor
        headerLabel.font = UIFont.systemFont(ofSize: titleSize, weight: .semibold)
    }
}

extension UIColor {
    static let snow = UIColor(named: "Snow")!
}
