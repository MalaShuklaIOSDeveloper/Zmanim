//
//  UITableView.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit

extension UITableView {
    func setupErrorView(with title: String, message: String) {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        let groupView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        titleLabel.text = title
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont.systemFont(ofSize: Constants.Alerts.Error.Network.TitleSize)
        titleLabel.sizeToFit()
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width/1.3, height: 85))
        messageLabel.text = message
        messageLabel.textColor = UIColor.lightGray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: Constants.Alerts.Error.Network.MessageSize)
        messageLabel.numberOfLines = 0
        groupView.bounds = CGRect(x: 0, y: 0, width: messageLabel.bounds.width, height: titleLabel.bounds.height + messageLabel.bounds.height)
        titleLabel.center = CGPoint(x: groupView.bounds.width/2, y: titleLabel.bounds.height/2)
        messageLabel.center = CGPoint(x: groupView.bounds.width/2, y: titleLabel.bounds.height + (messageLabel.bounds.height/2))
        groupView.addSubview(titleLabel)
        groupView.addSubview(messageLabel)
        groupView.center = containerView.center
        containerView.addSubview(groupView)
        backgroundView = containerView
        separatorColor = UIColor.clear
    }
    
    func setup(_ headerView: UIView, with height: CGFloat, in viewController: UIViewController? = nil, animated: Bool = false) {
        tableHeaderView = nil
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentInset.top = height
                self.contentOffset = CGPoint(x: 0, y: -height)
            }, completion: { completed in
                headerView.alpha = 0
                self.addSubview(headerView)
                UIView.animate(withDuration: 0.4, animations: {
                    headerView.alpha = 1
                })
            })
        } else {
            contentInset.top = height
            contentOffset = CGPoint(x: 0, y: -height)
            addSubview(headerView)
        }
        
        if let navigationController = viewController?.parent as? UINavigationController {
            scrollIndicatorInsets.top = navigationController.navigationBar.frame.size.height + 20
        }
    }
    
    func remove(_ headerView: UIView, in viewController: UIViewController? = nil, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                headerView.alpha = 0
                if let navigationController = viewController?.parent as? UINavigationController {
                    let inset = UIEdgeInsets(top: navigationController.navigationBar.frame.size.height + 20, left: 0, bottom: 0, right: 0)
                    self.contentInset = inset
                    self.scrollIndicatorInsets = inset
                } else {
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
            }) { completed in
                headerView.removeFromSuperview()
                headerView.alpha = 1
            }
        } else {
            headerView.removeFromSuperview()
            if let navigationController = viewController?.parent as? UINavigationController {
                let inset = UIEdgeInsets(top: navigationController.navigationBar.frame.size.height + 20, left: 0, bottom: 0, right: 0)
                contentInset = inset
                scrollIndicatorInsets = inset
            } else {
                contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    func update(_ headerView: UIView, with height: CGFloat) {
        var headerRect = CGRect(x: 0, y: -height, width: bounds.width, height: height)
        if contentOffset.y < -height {
            headerRect.origin.y = contentOffset.y
            headerRect.size.height = -contentOffset.y
        }
        headerView.frame = headerRect
    }
}
