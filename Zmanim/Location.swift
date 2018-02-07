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
    let title: String
    let directions: String?
    
    let latitude: Double
    let longitude: Double
    
    var imageURL: URL?
    var image: UIImage?
    
    var recognized = false
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
    }
}

extension Location {
    enum CodingKeys: String, CodingKey {
        case title = "name"
        case directions = "description"
        case coordinates
    }
    
    enum CoordinatesCodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

extension Location {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Location: CustomStringConvertible {
    var description: String {
        return "title: \(title)"
    }
}
