//
//  UIImageView.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImage(_ image: UIImage, withAnimationDuration duration: TimeInterval = 0, andCompletion completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: { self.image = image }, completion: completion)
    }
    
    func setup(with location: Location, animated: Bool, activityIndicator: UIActivityIndicatorView? = nil, completionHandler: (() -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        if let locationImage = location.image {
            if animated { setImage(locationImage, withAnimationDuration: 0.5) } else { image = locationImage }
            completionHandler?()
        } else if let locationImageURL = location.imageURL {
            locationImageURL.loadImage(with: activityIndicator, completionHandler: { image in
                location.image = image
                self.setup(with: location, animated: animated)
            }, errorHandler: errorHandler)
        } else {
            let yuImage = UIImage(named: Constants.Assets.Images.YU)!
            if animated { setImage(yuImage, withAnimationDuration: 0.5) } else { image = yuImage }
            completionHandler?()
        }
    }
}
