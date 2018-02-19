//
//  Location.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import UIKit
import CoreLocation

/// A type that represents a location 🕍 for minyan.
class Location: Decodable {
    /// The location's title.
    let title: String
    /// The directions the location can be located at.
    let directions: String?
    
    /// The latitude of the location.
    let latitude: Double
    /// The longitude of the location.
    let longitude: Double
    
    /// The URL to the location's image.
    var imageURL: URL?
    /// The location's local image or cache from `imageURL`.
    var image: UIImage?
    
    /// `true` if location is recognized by the API and `false` if not. Default is `false`.
    var recognized = false
    /// The current zmanim happening at the location.
    var zmanim: [Zman] = []
    
    init(title: String, directions: String? = nil, latitude: Double = 0, longitude: Double = 0, imageURL: URL? = nil, image: UIImage? = nil) {
        self.title = title
        self.directions = directions
        self.latitude = latitude
        self.longitude = longitude
        self.imageURL = imageURL
        self.image = image
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.directions = try container.decode(String.self, forKey: .directions)
        let coordinates = try container.nestedContainer(keyedBy: CoordinatesCodingKeys.self, forKey: .coordinates)
        self.latitude = try coordinates.decode(Double.self, forKey: .latitude)
        self.longitude = try coordinates.decode(Double.self, forKey: .longitude)
        
        if let image = LocationImages.image(forLocationTitle: self.title) {
            self.image = image
        }
        
        if let locationUserInfo = decoder.userInfo[CodingUserInfo.key] as? CodingUserInfo {
            self.recognized = locationUserInfo.recognized
        }
    }
}

extension Location {
    enum Title: String {
        case annex = "Annex"
        case fischelBeis = "Fischel Beis"
        case glueck2Lobby = "Glueck 2 Lobby"
        case glueck303 = "Glueck 303"
        case glueckBeis = "Glueck Beis"
        case mussBeis = "Muss Beis"
        case morgBeis = "Morg Beis"
        case morgLounge = "Morg Lounge"
        case rubinShul = "Rubin Shul"
        case sefardiBeitMidrash = "Sefardi Beit Midrash"
        case skyCaf = "Sky Caf"
        case zysman101 = "Zysman 101"
    }
}

extension Location {
    enum CodingKeys: String, CodingKey {
        case title = "name"
        case directions = "description"
        case coordinates
    }
    
    /// A type that represents user info to pass to a decoder.
    struct CodingUserInfo {
        static let key = CodingUserInfoKey(rawValue: "locationCodingOptions")!
        let recognized: Bool
    }
    
    /// A decoder error.
    enum CoordinatesCodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

extension Location: Equatable {
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.title == rhs.title
    }
}

extension Location {
    /// The coordinate of the location composed of `latitude` and `longitude`.
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Location: CustomStringConvertible {
    var description: String {
        return "title: \(title)"
    }
}
