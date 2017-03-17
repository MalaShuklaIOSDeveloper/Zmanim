//
//  Watch Extensions.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2016 Natanel Niazoff. All rights reserved.
//

import Foundation
import WatchKit

// WKInterfaceController
extension WKInterfaceController {
    func presentAlertController(title: String? = nil, message: String? = nil, prefferedStyle: WKAlertControllerStyle = .alert, actions: [WKAlertAction] = [], withCancelAction: Bool = false, cancelActionTitle: String = Constants.Alerts.Actions.Cancel, cancelActionHandler: WKAlertActionHandler? = nil) {
        var actions = actions
        if withCancelAction {
            let cancelAction = WKAlertAction(title: cancelActionTitle, style: .cancel) {
                cancelActionHandler?()
            }
            actions.append(cancelAction)
        }
        presentAlert(withTitle: title, message: message, preferredStyle: prefferedStyle, actions: actions)
    }
}
