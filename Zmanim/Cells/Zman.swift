//
//  Zman.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationAction: UIAlertAction {
    var notificationRequest: UNNotificationRequest!
    var notificationIsPending = false
}

protocol ZmanTableViewCellDelegate {
    func notifyButtonTappedInZmanCell(_ cell: ZmanTableViewCell)
}

class ZmanTableViewCell: UITableViewCell {
    // MARK: Properties
    var delegate: ZmanTableViewCellDelegate?
    var tefillah: Tefillah!
    var zman: Zman!
    var location: Location!
    var notifyButtonImage: UIImage {
        if atLeastOneNotificationScheduled {
            return UIImage(named: Constants.Assets.Images.BellFull)!
        }
        return UIImage(named: Constants.Assets.Images.BellOutline)!
    }
    
    var notificationActions = [NotificationAction]()
    var atLeastOneNotificationScheduled = false {
        didSet {
            self.notifyButton.setImage(self.notifyButtonImage, for: UIControlState())
        }
    }
    
    var notifyAlertController: UIAlertController {
        var alertActions = [UIAlertAction]()
        for notificationAction in notificationActions {
            let nextTriggerDateComponents = (notificationAction.notificationRequest.trigger as! UNCalendarNotificationTrigger).dateComponents
            let nextTriggerDate = Calendar.current.date(from: nextTriggerDateComponents)!
            if nextTriggerDate.isGreaterThanDate(Date()) {
                if !notificationAction.notificationIsPending {
                    alertActions.append(notificationAction)
                }
            }
        }
        if atLeastOneNotificationScheduled {
            let cancelScheduledNotificationsAction = UIAlertAction(title: Constants.Zmanim.ZmanTableViewCell.Alerts.Notify.CancelAll, style: .default) { action in
                self.notificationActions.forEach { action in
                    if action.notificationIsPending {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [action.notificationRequest.identifier])
                        action.notificationIsPending = false
                        self.notifyButton.setImage(self.notifyButtonImage, for: UIControlState())
                    }
                }
                self.atLeastOneNotificationScheduled = false
            }
            alertActions.append(cancelScheduledNotificationsAction)
        }
        if alertActions.isEmpty {
            return UIAlertController(title: Constants.Zmanim.ZmanTableViewCell.Alerts.CantNotify.Title, message: Constants.Zmanim.ZmanTableViewCell.Alerts.CantNotify.Message, preferredStyle: .alert, actions: [], withCancelAction: true, cancelActionTitle: Constants.Alerts.Actions.OK)
        } else {
            return UIAlertController(title: Constants.Zmanim.ZmanTableViewCell.Alerts.Notify.NotifyMe, preferredStyle: .actionSheet, actions: alertActions, withCancelAction: true, cancelActionHandler: { action, viewController in
                viewController?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    // MARK: Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        notificationActions = [
            notificationActionWithPriorMinutes(5),
            notificationActionWithPriorMinutes(10),
            notificationActionWithPriorMinutes(30)
        ]
        
        notifyButton.setImage(notifyButtonImage, for: UIControlState())
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notifyButton: UIButton! {
        didSet {
            notifyButton.adjustsImageWhenHighlighted = false
            notifyButton.contentMode = .scaleAspectFit
            notifyButton.setImage(notifyButtonImage, for: UIControlState())
            notifyButton.addTarget(self, action: #selector(ZmanTableViewCell.selectNotifyButton(_:)), for: .touchDown)
            notifyButton.addTarget(self, action: #selector(ZmanTableViewCell.deselectNotifyButton(_:)), for: .touchDragExit)
            notifyButton.addTarget(self, action: #selector(ZmanTableViewCell.deselectNotifyButton(_:)), for: .touchUpInside)
        }
    }
    
    //MARK: Methods
    func notificationActionWithPriorMinutes(_ minutes: Int) -> NotificationAction {
        let notificationAction = NotificationAction(title: "\(minutes) Minutes Before", style: .default) { action in
            let notificationAction = action as! NotificationAction
            UNUserNotificationCenter.current().add(notificationAction.notificationRequest) { error in
                
            }
            notificationAction.notificationIsPending = true
            self.atLeastOneNotificationScheduled = true
        }
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutes, to: zman.date)!
        var triggerDateComponents = Calendar.current.dateComponents(Calendar.Component.allComponents, from: triggerDate)
        // FIXME: quarter
        triggerDateComponents.quarter = 1
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = Constants.Notifications.ZmanReminder.Title
        notificationContent.body = "\(tefillah.title) at \(location.title!) starts in \(minutes) minutes at \(zman.date.shortTimeString)."
        notificationContent.sound = .default()
        notificationAction.notificationRequest = UNNotificationRequest(identifier: "\(triggerDate.timeIntervalSinceReferenceDate)", content: notificationContent, trigger: notificationTrigger)
        return notificationAction
    }
    
    func getNotificationActionsWithPendingRequests(completionHandler: @escaping ([NotificationAction]) -> Void) {
        var actions = [NotificationAction]()
        UNUserNotificationCenter.current().getPendingNotificationRequests() { requests in
            DispatchQueue.main.async {
                requests.forEach { request in
                    self.notificationActions.forEach { notificationAction in
                        if notificationAction.notificationRequest.identifier == request.identifier {
                            actions.append(notificationAction)
                        }
                    }
                }
                completionHandler(actions)
            }
        }
    }
    
    func selectNotifyButton(_ sender: UIButton) {
        sender.alpha = 0.5
    }
    
    func deselectNotifyButton(_ sender: UIButton) {
        sender.alpha = 1
    }
    
    // MARK: IBActions
    @IBAction func notifyButtonTapped(_ sender: UIButton) {
        delegate?.notifyButtonTappedInZmanCell(self)
    }
}
