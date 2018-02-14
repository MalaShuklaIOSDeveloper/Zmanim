//
//  RoundButton.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/14/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit

@IBDesignable class RoundButton: UIButton {
    private let backgroundShape = CAShapeLayer()
    
    // MARK: - Overrided Properties
    @IBInspectable override var backgroundColor: UIColor? {
        get {
            if let color = backgroundShape.fillColor {
                return UIColor(cgColor: color)
            }
            return nil
        } set {
            backgroundShape.fillColor = newValue?.cgColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else { return }
            animateHighlight()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setup()
    }
    
    func setup() {
        layer.masksToBounds = false
        layer.cornerRadius = bounds.height/2
        
        backgroundShape.frame = bounds
        backgroundShape.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.insertSublayer(backgroundShape, at: 0)
    }
    
    func animateHighlight() {
        if isHighlighted {
            UIView.animate(withDuration: 0.1) {
                self.alpha = 0.8
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
}
