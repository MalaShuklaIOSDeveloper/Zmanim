//
//  ZmanimDataSource.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

@objc protocol ZmanimDataSourceDelegate {
    @objc optional func handleZmanimFetchCompletion()
    @objc optional func handleZmanimFetchError(_ error: Error)
    @objc optional func handleShabbosFetchCompletion()
    @objc optional func handleShabbosFetchError(_ error: Error)
    @objc optional func handleLocalZmanimFetchCompletion()
    @objc optional func handleLocalZmanimFetchError(_ error: Error)
    @objc optional func handleSelichosFetchCompletion()
    @objc optional func handleSelichosFetchError(_ error: Error)
}

class ZmanimDataSource {
    static let dataSource = ZmanimDataSource()
    var date = Date()
    var delegate: ZmanimDataSourceDelegate?
    var zmanim: [Zman]?
    var locations: [Location]?
    var shabbos: Shabbos?
    var localZmanim: [LocalZman]?
    var nightSelichos: [Selichos]?
    var daySelichos: [Selichos]?
    // TODO: do some more research
    var isFetchingZmanim: Bool = false
    
    fileprivate init() {}
    
    func zmanimForTefillah(_ tefillah: Tefillah) -> [Zman]? {
        var zmanimToReturn = [Zman]()
        if zmanim != nil {
            for zman in zmanim! {
                if zman.tefillah == tefillah {
                    zmanimToReturn.append(zman)
                }
            }
        } else {
            return nil
        }
        return zmanimToReturn
    }
    
    // Methods used to fetch data from API and configure with model
    func fetchAndConfigureZmanim(for date: Date = Date(), delegateCompletion: Bool = true, delegateError: Bool = true) {
        locations = nil
        zmanim = nil
        isFetchingZmanim = true
        
        // Starts off by fetching locations from data service
        ZmanimDataServices.fetchLocations({ fetchedLocationsData in
            if let fetchedLocations = fetchedLocationsData["data"] as? [[String: Any]] {
                for fetchedLocation in fetchedLocations {
                    guard let title = fetchedLocation["name"] as? String,
                        let directions = fetchedLocation["details"] as? String,
                        let imageURLString = fetchedLocation["picture"] as? String,
                        let coordinates = fetchedLocation["geo"] as? [String: String],
                        let latitudeString = coordinates["latitude"],
                        let longitudeString = coordinates["longitude"] else { return }
                    let imageURL = URL(string: imageURLString)
                    let image = LocationImages.locationImageForTitle(title)
                    let latitude = Double(latitudeString) ?? 0
                    let longitude = Double(longitudeString) ?? 0
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    let location = Location(title: title, directions: directions, imageURL: imageURL, image: image, coordinate: coordinate)
                    if self.locations != nil {
                        self.locations!.append(location)
                    } else {
                        self.locations = [location]
                    }
                }
            }
            
            func newDate(for string: String, with tefillah: Tefillah, date: Date) -> Date {
                let dateComponents = Calendar.current.dateComponents([.year, .day, .month], from: date)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm"
                let dateFromString = dateFormatter.date(from: string)!
                var newDateComponents = DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day)
                newDateComponents.hour = dateFromString.hour
                newDateComponents.minute = dateFromString.minute
                newDateComponents.second = 0
                let newDate = Calendar.current.date(from: newDateComponents)!
                if tefillah == .mincha {
                    return Calendar.current.date(byAdding: .hour, value: 12, to: newDate)!
                } else if tefillah == .maariv {
                    if newDateComponents.hour == 0 || newDateComponents.hour == 1 {
                        return Calendar.current.date(byAdding: .day, value: 1, to: newDate)!
                    }
                    return Calendar.current.date(byAdding: .hour, value: 12, to: newDate)!
                }
                return newDate
            }
            
            func configure(_ fetchedTefillah: ZmanimDataServices.Zmanim, for tefillah: Tefillah, with date: Date) {
                guard let fetchedTefillahData = fetchedTefillah["data"] as? [String: Any],
                    let fetchedZmanimData = fetchedTefillahData["tefillos"] as? [[String: Any]] else { return }
                for fetchedZmanData in fetchedZmanimData {
                    guard let time = fetchedZmanData["time"] as? String,
                    let locationTitle = fetchedZmanData["name"] as? String else { break }
                    let zmanDate = newDate(for: time, with: tefillah, date: date)
                    // Starts off by assuming zman location is not recognized and sets only the title and image
                    let zmanLocationImage = LocationImages.locationImageForTitle(locationTitle)
                    var zmanLocation = Location(title: locationTitle, image: zmanLocationImage, recognized: false)
                    // If a location's title matches the location title, location is asssigned as zman location
                    for location in self.locations! {
                        if zmanLocation.title!.contains(location.title!) {
                            /* This pattern doesn't take into account the possibility that there can be two locations for any given title but this should be avoided by the API. Instead there should be two seperate dictionaries in the tefillah array with the same time.  */
                            zmanLocation = location
                        }
                    }
                    let zman = Zman(tefillah: tefillah, date: zmanDate, locations: [zmanLocation])
                    self.appendZman(zman)
                }
            }
            
            let tefillos: [Tefillah] = [.shacharis, .mincha, .maariv]
            // Fetches zmanim from data service
            ZmanimDataServices.fetchZmanim(for: date, tefillos: tefillos, completionHandler: { fetchedTefillos in
                var shacharis = (ZmanimDataServices.Zmanim(), Tefillah.shacharis)
                var mincha = (ZmanimDataServices.Zmanim(), Tefillah.mincha)
                var maariv = (ZmanimDataServices.Zmanim(), Tefillah.maariv)
                for (fetchedTefillah, fetchedZmanim) in fetchedTefillos {
                    switch fetchedTefillah {
                    case .shacharis: shacharis.0 = fetchedZmanim
                    case .mincha: mincha.0 = fetchedZmanim
                    case .maariv: maariv.0 = fetchedZmanim
                    }
                }
                for (fetchedZmanim, fetchedTefillah) in [shacharis, mincha, maariv] {
                    configure(fetchedZmanim, for: fetchedTefillah, with: date)
                }
                
                //Adds zman to respective location
                if self.locations != nil {
                    for location in self.locations! {
                        if self.zmanim != nil {
                            for zman in self.zmanim! {
                                for zmanLocation in zman.locations {
                                    if zmanLocation.title == location.title {
                                        location.zmanim.append(zman)
                                    }
                                }
                            }
                        }
                    }
                }
                self.isFetchingZmanim = false
                if delegateCompletion {
                    self.delegate?.handleZmanimFetchCompletion?()
                }
            }, errorHandler: nil)
        }, errorHandler: { error in
            self.isFetchingZmanim = false
            if delegateError {
                self.delegate?.handleZmanimFetchError?(error)
            }
        })
    }
    
    func fetchAndConfigureShabbos(delegateCompletion: Bool = true, delegateError: Bool = true) {
        shabbos = nil
        
        ZmanimDataServices.fetchShabbos({ fetchedShabbos in
            guard let fetchedShabbosData = fetchedShabbos["data"] as? [String: Any],
                let parsha = fetchedShabbosData["parsha"] as? String,
                let pdfURLString = fetchedShabbosData["link"] as? String else { return }
            let pdfURL = URL(string: pdfURLString)
            self.shabbos = Shabbos(parsha: parsha, url: pdfURL ?? URL(string: Constants.URLs.YUZmanim.Shabbos)!)
            if delegateCompletion {
                self.delegate?.handleShabbosFetchCompletion?()
            }
        }, errorHandler: { error in
            if delegateError {
                self.delegate?.handleShabbosFetchError?(error)
            }
        })
    }
    
    func fetchAndConfigureLocalZmanim(for date: Date = Date(), delegateCompletion: Bool = true, delegateError: Bool = true) {
        localZmanim = nil
        
        func newDate(from string: String, date: Date) -> Date {
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm:ss a"
            let dateFromString = dateFormatter.date(from: string)!
            var newDateComponents = Calendar.current.dateComponents([.second, .minute, .hour], from: dateFromString)
            newDateComponents.day = dateComponents.day
            newDateComponents.month = dateComponents.month
            newDateComponents.year = dateComponents.year
            var newDate = Calendar.current.date(from: newDateComponents)!
            if newDateComponents.hour == 0 || newDateComponents.hour == 1 {
                newDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate)!
            }
            return newDate
        }
        
        ZmanimDataServices.fetchLocalZmanim(for: date, completionHandler: { fetchedLocalZmanim in
            guard let fetchedLocalZmanimData = (fetchedLocalZmanim["data"] as! [String: Any])["tefillos"] as? [[String: Any]]
                else { return }
            for fetchedLocalZman in fetchedLocalZmanimData {
                guard let title = fetchedLocalZman["name"] as? String,
                    let time = fetchedLocalZman["time"] as? String else { return }
                let localZman = LocalZman(title: title, date: newDate(from: time, date: self.date))
                if self.localZmanim != nil {
                    self.localZmanim!.append(localZman)
                } else {
                    self.localZmanim = [localZman]
                }
            }
            if delegateCompletion {
                self.delegate?.handleLocalZmanimFetchCompletion?()
            }
            }, errorHandler: { error in
                if delegateError {
                    self.delegate?.handleLocalZmanimFetchError?(error)
                }
            })
    }
    
    // Method used to append a new zman to given zmanim
    fileprivate func appendZman(_ newZman: Zman) {
        // If zmanim is nil array of zmanim is set with new zman
        if zmanim != nil {
            // If zmanim is empty, normally appends to it
            if zmanim!.isEmpty {
                zmanim!.append(newZman)
            } else {
                var appendedToLocations = false
                for zman in zmanim! {
                    // If new zman has same time as given zmanim zman appends new zman's location to the zman's location array
                    if newZman.date == zman.date {
                        // New zman should only have one location in it's array
                        zman.locations.append(newZman.locations.first!)
                        appendedToLocations = true
                    }
                }
                if !appendedToLocations {
                    zmanim!.append(newZman)
                }
            }
        } else {
            zmanim = [newZman]
        }
    }
}
