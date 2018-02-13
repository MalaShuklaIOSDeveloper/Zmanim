//
//  ZmanimAPIClient.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

typealias JSON = [String : Any]
typealias Zmanim = [Tefillah : [Zman]]

/// The result the API returns with.
enum APIResult<T> {
    case success(T)
    case failure(Error)
}

/**
 A type that is able to observe updates to `UserAPIClient`.
 */
protocol ZmanimAPIObserver {
    /// A unique id to identify the specific observer. Primarily used to remove the observer from observing.
    var id: String { get }
    
    var zmanimDidChange: ((Zmanim) -> Void) { get }
    
    var locationsDidChange: (([Location]) -> Void) { get }
    
    var localZmanimDidChange: (([LocalZman]) -> Void) { get }
}

/// A singleton class that stores observers to `UserAPIClient`.
private class ZmanimAPIObservers {
    /// The shared singleton property.
    static let shared = ZmanimAPIObservers()
    
    /// The array of observers.
    var observers = [ZmanimAPIObserver]()
    
    private init() {}
}

/// A client for fetching data from the API 🏭.
struct ZmanimAPIClient {
    private struct Constants {
        static let baseAPIURL = "http://zmanimapp.com:5000/api"
    }
    
    // MARK: - Observers
    private static var observers: [ZmanimAPIObserver] {
        get {
            return ZmanimAPIObservers.shared.observers
        } set {
            ZmanimAPIObservers.shared.observers = newValue
        }
    }
    
    static func addObserver(_ observer: ZmanimAPIObserver) {
        observers.append(observer)
    }
    
    static func removeObserver(_ observer: ZmanimAPIObserver) {
        // Filter observer array to disclude the given observer by its unique id.
        observers = observers.filter { $0.id != observer.id }
    }
    
    // MARK: - Zmanim
    /**
    Fetches zmanim and parses to `Zman` objects without respective `Location` objects from API and calls `completed` upon returning with result.
    */
    private static func fetchRawZmanim(for date: Date, completed: @escaping (_ result: APIResult<Zmanim>) -> Void) {
        var zmanim = Zmanim()
        for tefillah in Tefillah.allTefillos {
            let url = Constants.baseAPIURL.tefillos + "/\(tefillah.rawValue)/\(date.apiFormat)"
            Alamofire.request(url).responseJSON { response in
                switch response.result {
                case .success:
                    if let zmanimData = response.data {
                        do {
                            let decoder = JSONDecoder()
                            decoder.userInfo[Zman.CodingUserInfo.key] = Zman.CodingUserInfo(tefillah: tefillah, date: date)
                            let rawZmanim = try decoder.decode(RawZmanim.self, from: zmanimData)
                            zmanim[tefillah] = rawZmanim.data.teffilos
                            if zmanim.count == Tefillah.allTefillos.count {
                                completed(.success(zmanim))
                            }
                        } catch {
                            completed(.failure(error))
                        }
                    }
                case .failure(let error):
                    completed(.failure(error))
                    return
                }
            }
        }
    }
    
    /**
     Fetches zmanim and locations and parses to `Zman` objects with respective `Location` objects from API and calls `completed` upon returning with result. Sends zmanim and locations to observers.
    */
    static func fetchZmanim(for date: Date, completed: ((_ result: APIResult<Zmanim>) -> Void)? = nil) {
        fetchLocations { result in
            switch result {
            // If fetched locations successfully...
            case .success(let locations):
                fetchRawZmanim(for: date) { result in
                    switch result {
                    case .success(var zmanim):
                        // ...if fetched zmanim successfully...
                        // ...for each tefillah...
                        for tefillah in Tefillah.allTefillos {
                            if let tefillahZmanim = zmanim[tefillah] {
                                // ...and each zman...
                                for zman in tefillahZmanim {
                                    // ...for each zman's raw location...
                                    for (zmanLocationIndex, var zmanLocation) in zman.locations.enumerated() {
                                        // ...for each location from before...
                                        for location in locations {
                                            // ...if the zman's raw location matches the location...
                                            if zmanLocation.title.contains(location.title) {
                                                // ...change `zmanLocation` to the location...
                                                zmanLocation = location
                                                // FIXME: REFERENCE CYCLE
                                                // ...assign the location to the zman...
                                                zman.locations[zmanLocationIndex] = zmanLocation
                                                // ...and add the zman to the location.
                                                location.zmanim.append(zman)
                                            }
                                        }
                                    }
                                }
                                // Combines zmanim with multiple locations into one zman.
                                zmanim[tefillah] = tefillahZmanim.reduce([Zman]()) { result, currentZman in
                                    // If there's a previous zman...
                                    if let prevZman = result.last {
                                        // ...and it's equal to the current one...
                                        if prevZman == currentZman {
                                            // ...add the current zman's locations to the previous zman...
                                            prevZman.locations += currentZman.locations
                                            // ...and only return the previous zman.
                                            return result
                                        }
                                    }
                                    // If there's no previous zman or it's not equal to the current one, add it to the array.
                                    return result + [currentZman]
                                }
                            }
                        }
                        // Send to observers.
                        observers.forEach { $0.zmanimDidChange(zmanim) }
                        observers.forEach { $0.locationsDidChange(locations) }
                        completed?(.success(zmanim))
                    case .failure(let error):
                        completed?(.failure(error))
                    }
                }
            case .failure(let error):
                completed?(.failure(error))
            }
        }
    }
    
    // MARK: - Locations
    /**
     Fetches locations and parses to `Location` objects without respective `Zman` objects from API and calls `completed` upon returning with result.
    */
    static func fetchLocations(_ completed: @escaping (_ result: APIResult<[Location]>) -> Void) {
        let url = Constants.baseAPIURL.locations
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success:
                if let locationsData = response.data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.userInfo[Location.CodingUserInfo.key] = Location.CodingUserInfo(recognized: true)
                        let rawLocations = try decoder.decode(RawLocations.self, from: locationsData)
                        completed(.success(rawLocations.locations))
                    } catch {
                        completed(.failure(error))
                    }
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    // MARK: - Local Zmanim
    /// Fetches local zmanim from API and calls `completed` upon returning with result.
    static func fetchLocalZmanim(for date: Date, completed: @escaping (_ result: APIResult<[LocalZman]>) -> Void) {
        let url = Constants.baseAPIURL.zmanim
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success:
                if let localZmanimData = response.data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.userInfo[Location.CodingUserInfo.key] = LocalZman.CodingUserInfo(date: date)
                        let rawLocalZmanim = try decoder.decode(RawLocalZmanim.self, from: localZmanimData)
                        observers.forEach { $0.localZmanimDidChange(rawLocalZmanim.zmanim) }
                        completed(.success(rawLocalZmanim.zmanim))
                    } catch {
                        completed(.failure(error))
                    }
                }
            case.failure(let error):
                completed(.failure(error))
            }
        }
    }
}

/// A type that represents decodable raw zmanim from API JSON.
private struct RawZmanim: Decodable {
    let data: Data
    
    struct Data: Decodable {
        let teffilos: [Zman]
    }
}

/// A type that represents decodable raw locations from API JSON.
private struct RawLocations: Decodable {
    let locations: [Location]
}

/// A type that represents decodable raw local zmanim from API JSON.
private struct RawLocalZmanim: Decodable {
    let zmanim: [LocalZman]
}

private extension String {
    var tefillos: String {
        return self + "/tefillos"
    }
    
    var locations: String {
        return self + "/locations"
    }
    
    var zmanim: String {
        return self + "/zmanim"
    }
}

private extension Date {
    var apiFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: self)
    }
}
