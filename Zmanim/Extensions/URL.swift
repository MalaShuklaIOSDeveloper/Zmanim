//
//  URL.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import UIKit
import SafariServices

extension URL {
    static func canOpen(_ url: String) -> Bool {
        let application = UIApplication.shared
        if let urlFromString = URL(string: url) {
            if application.canOpenURL(urlFromString) {
                return true
            }
        }
        return false
    }
    
    static func open(_ url: String, completionHandler: ((Bool) -> Void)? = nil) {
        let application = UIApplication.shared
        if let urlFromString = URL(string: url) {
            application.open(urlFromString, options: [:], completionHandler: completionHandler)
        }
    }
    
    func loadImage(with activityIndicator: UIActivityIndicatorView? = nil, completionHandler: ((UIImage) -> Void)? = nil, errorHandler: (() -> Void)? = nil) {
        activityIndicator?.startAnimating()
        DispatchQueue(label: "", qos: .userInitiated).async {
            let imageData = try? Data(contentsOf: self)
            DispatchQueue.main.async {
                if imageData != nil {
                    activityIndicator?.stopAnimating()
                    completionHandler?(UIImage(data: imageData!)!)
                } else {
                    activityIndicator?.stopAnimating()
                    errorHandler?()
                }
            }
        }
    }
    
    func loadInSafariViewController(in viewController: UIViewController) {
        let shabbosSafariViewController = SFSafariViewController(url: self)
        let navigationViewController = UINavigationController(rootViewController: shabbosSafariViewController)
        navigationViewController.setNavigationBarHidden(true, animated: false)
        viewController.present(navigationViewController, animated: true, completion: nil)
    }
}
