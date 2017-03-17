//
//  UIViewController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlertController(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .alert, actions: [UIAlertAction] = [], withCancelAction: Bool = false, cancelActionTitle: String = Constants.Alerts.Actions.Cancel, cancelActionHandler: ((UIAlertAction, UIViewController?) -> Void)? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle, actions: actions, withCancelAction: withCancelAction, cancelActionTitle: cancelActionTitle, cancelActionHandler: cancelActionHandler)
        present(alertViewController, animated: animated, completion: completion)
    }
}
