//
//  ZmanimAPIClient.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import Alamofire

/// The result the API returns with.
enum APIResult<T> {
    case success(T)
    case failure(Error)
}

/// A client for fetching data from the API.
struct ZmanimAPIClient {
    typealias JSON = [String : Any]
    typealias Zmanim = [Tefillah : [Zman]]
    
    private static let baseAPIURL = "http://zmanimapp.com:5000/api"
    
    // MARK: - Zmanim
    /// Fetches zmanim without location objects from API and calls `completed` upon returning with result.
    private static func fetchRawZmanim(for date: Date, completed: @escaping (_ result: APIResult<Zmanim>) -> Void) {
        var zmanim = Zmanim()
        for tefillah in Tefillah.allTefillos {
            let url = baseAPIURL.tefillos + "/\(tefillah.rawValue)"
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
    
    /// Fetches zmanim from API and calls `completed` upon returning with result.
    static func fetchZmanim(for date: Date, completed: @escaping (_ result: APIResult<Zmanim>) -> Void) {
        fetchLocations { result in
            switch result {
            case .success(let locations):
                fetchRawZmanim(for: date) { result in
                    switch result {
                    case .success(let zmanim):
                        for tefillah in Tefillah.allTefillos {
                            if let zmanim = zmanim[tefillah] {
                                for zman in zmanim {
                                    for (index, zmanLocation) in zman.locations.enumerated() {
                                        for location in locations {
                                            if zmanLocation.title.contains(location.title) {
                                                // FIXME: Reference cycle
                                                zman.locations[index] = location
                                                location.zmanim.append(zman)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        completed(.success(zmanim))
                    case .failure(let error):
                        completed(.failure(error))
                    }
                }
            case .failure(let error):
                completed(.failure(error))
            }
        }
    }
    
    // MARK: Locations
    /// Fetches locations from API and calls `completed` upon returning with result.
    static func fetchLocations(_ completed: @escaping (_ result: APIResult<[Location]>) -> Void) {
        let url = baseAPIURL.locations
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success:
                if let locationsData = response.data {
                    do {
                        let rawLocations = try JSONDecoder().decode(RawLocations.self, from: locationsData)
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
    
    // MARK: Local Zmanim
    /// Fetches local zmanim from API and calls `completed` upon returning with result.
    static func fetchLocalZmanim(for date: Date, completed: @escaping (_ result: APIResult<[LocalZman]>) -> Void) {
        let url = baseAPIURL.zmanim
        Alamofire.request(url).responseJSON { response in
//            switch response.result {
//            case .success:
//
//            case.failure(let error):
//                completed(.failure(error))
//            }
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
