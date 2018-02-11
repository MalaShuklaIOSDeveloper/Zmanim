//
//  URL.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import SafariServices

extension URL {
    static func canOpen(_ urlString: String) -> Bool {
        let application = UIApplication.shared
        if let url = URL(string: urlString) {
            return application.canOpenURL(url)
        }
        return false
    }
    
    static func open(_ urlString: String, completionHandler: ((Bool) -> Void)? = nil) {
        let application = UIApplication.shared
        if let url = URL(string: urlString) {
            application.open(url, options: [:], completionHandler: completionHandler)
        }
    }
}
