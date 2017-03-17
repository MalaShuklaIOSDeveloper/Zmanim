//
//  UIAlertController.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

extension UIAlertController {
    convenience init(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle = .alert, actions: [UIAlertAction], withCancelAction: Bool = false, cancelActionTitle: String = Constants.Alerts.Actions.Cancel, cancelActionHandler: ((UIAlertAction, UIViewController?) -> Void)? = nil) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            addAction(action)
        }
        if withCancelAction {
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel) { action in
                cancelActionHandler?(action, self.presentingViewController)
            }
            addAction(cancelAction)
        }
    }
}
