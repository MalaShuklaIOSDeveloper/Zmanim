//
//  ZmanimDataServices.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

struct ZmanimDataServices {
    typealias Zmanim = [String: Any]
    typealias Locations = [String: Any]
    typealias ShabbosDictionary = [String: Any]
    typealias LocalZmanim = [String: Any]
    
    // MARK: Zmanim Fetch
    static func fetchZmanim(for date: Date, tefillos: [Tefillah], completionHandler: (([Tefillah: Zmanim]) -> Void)?, errorHandler: ((Error) -> Void)?) {
        var fetchedTefillos = [Tefillah: Zmanim]()
        for tefillah in tefillos {
        let url = Constants.URLs.YUZmanimAPI.Tefillos + "?tefillah=\(tefillah.rawValue)&day=\(date.shortDateString)"
        Alamofire.request(url).responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let fetchedZmanim = value as? Zmanim {
                        fetchedTefillos[tefillah] = fetchedZmanim
                        if fetchedTefillos.count == 3 {
                            completionHandler?(fetchedTefillos)
                        }
                    }
                case .failure(let error):
                    errorHandler?(error)
                    return
                }
            }
        }
    }
    
    // MARK: Location Fetch
    static func fetchLocations(_ completionHandler: ((Locations) -> Void)?, errorHandler: ((Error) -> Void)?) {
        Alamofire.request(Constants.URLs.YUZmanimAPI.Locations).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let fetchedLocations = value as? Locations {
                    completionHandler?(fetchedLocations)
                }
            case.failure(let error):
                errorHandler?(error)
            }
        }
    }
    
    // MARK: Shabbos Fetch
    static func fetchShabbos(_ completionHandler: ((ShabbosDictionary) -> Void)?, errorHandler: ((Error) -> Void)?) {
        Alamofire.request(Constants.URLs.YUZmanimAPI.Shabbos).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let fetchedShabbos = value as? ShabbosDictionary {
                    completionHandler?(fetchedShabbos)
                }
            case.failure(let error):
                errorHandler?(error)
            }
        }
    }
    
    // MARK: Local Zmanim Fetch
    static func fetchLocalZmanim(for date: Date, completionHandler: ((LocalZmanim) -> Void)?, errorHandler: ((Error) -> Void)?) {
        Alamofire.request(Constants.URLs.YUZmanimAPI.Tefillos + "?tefillah=local-zmanim&day=\(date.shortDateString)").responseJSON { response in
            switch response.result {
            case .success(let value):
                if let fetchedShabbos = value as? LocalZmanim {
                    completionHandler?(fetchedShabbos)
                } 
            case.failure(let error):
                errorHandler?(error)
            }
        }
    }
}
