//
//  AnimatedController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

@objc protocol AnimatedControllerDelegate {
    @objc optional func animationEndedSuccessfully()
}

enum TransitionType {
    case springSlideUp
    case slideDown
}

class AnimatedController: NSObject {
    // MARK: Properties
    fileprivate var transitionType: TransitionType
    fileprivate var duration: TimeInterval
    
    var delegate: AnimatedControllerDelegate?
    
    init(type: TransitionType = .springSlideUp, duration: TimeInterval = 1) {
        self.transitionType = type
        self.duration = duration
    }
    
    // MARK: Methods
    func animationEnded(_ transitionCompleted: Bool) {
        if transitionCompleted {
            delegate?.animationEndedSuccessfully?()
        }
    }
}

extension AnimatedController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        
        let container = transitionContext.containerView
        let finalFrameForToViewController = transitionContext.finalFrame(for: toViewController)
        
        switch transitionType {
        case .springSlideUp:
            toViewController.view.frame = finalFrameForToViewController.offsetBy(dx: 0, dy: container.frame.size.height)
            container.addSubview(toViewController.view)
        
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
                    fromViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    fromViewController.view.alpha = 0.5
                    toViewController.view.frame = finalFrameForToViewController
                }) { completed in
                    fromViewController.view.transform = CGAffineTransform.identity
                    fromViewController.view.alpha = 1
                    transitionContext.completeTransition(completed)
            }
        case .slideDown:
            toViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            toViewController.view.alpha = 0.5
            
            container.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromViewController.view.frame = fromViewController.view.frame.offsetBy(dx: 0, dy: container.frame.size.height)
                toViewController.view.transform = CGAffineTransform.identity
                toViewController.view.alpha = 1
            }, completion: { completed in
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(completed)
            }) 
        }
    }
}
