//
//  Ad.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

// TODO: move
class Target {
    let target: AnyObject?
    let action: Selector
    let controlEvents: UIControlEvents
    
    init(target: AnyObject?, action: Selector, controlEvents: UIControlEvents) {
        self.target = target
        self.action = action
        self.controlEvents = controlEvents
    }
}

class AdView: UIView {
    override var isHidden: Bool {
        get {
            return super.isHidden
        } set {
            if newValue {
                UIView.animate(withDuration: 0.2, animations: {
                    self.transform =
                        CGAffineTransform(translationX: 0, y: 60)
                }, completion: { completed in
                    super.isHidden = newValue
                }) 
            } else {
                super.isHidden = newValue
                UIView.animate(withDuration: 0.2, animations: {
                    self.transform = CGAffineTransform.identity
                }) 
            }
        }
    }
    
    // TODO: change to layout for landscape
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            translatesAutoresizingMaskIntoConstraints = false
            let adBottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
            let adLeadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
            let adTrailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
            let adHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
            superview!.addConstraints([adBottomConstraint, adLeadingConstraint, adTrailingConstraint, adHeightConstraint])
        }
    }
}

class AdButtonView: AdView {
    let button = UIButton(type: .custom)
    
    init(image: UIImage, frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        
        button.setImage(image, for: UIControlState())
        button.backgroundColor = UIColor.white
        button.imageView?.contentMode = .scaleAspectFill
        button.adjustsImageWhenHighlighted = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview(){
        super.didMoveToSuperview()
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonTopConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let buttonBottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let buttonLeadingConstraint = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let buttonTrailingConstraint = NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        addConstraints([buttonTopConstraint, buttonBottomConstraint, buttonLeadingConstraint, buttonTrailingConstraint])
    }
    
    func addTarget(_ target: Target) {
        button.addTarget(target.target, action: target.action, for: target.controlEvents)
    }
    
    func addTargets(_ targets: [Target]) {
        for target in targets {
            addTarget(target)
        }
    }
}
