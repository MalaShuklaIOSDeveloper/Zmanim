//
//  ZmanimModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class Zman {
    let tefillah: Tefillah
    let date: Date
    var locations: [Location]
    var next: Bool
    
    init(tefillah: Tefillah, date: Date, locations: [Location], next: Bool = false) {
        self.tefillah = tefillah
        self.date = date
        self.locations = locations
        self.next = next
    }
}

extension Zman: CustomStringConvertible {
    var description: String {
        return "tefillah: \(tefillah), time: \(date.description(with: Locale.current))"
    }
}

extension Zman: Equatable {
    static func ==(lhs: Zman, rhs: Zman) -> Bool {
        return lhs.date == rhs.date && lhs.tefillah == rhs.tefillah
        // TODO: add locations so that nextZman will have same location
    }
}

class Location: NSObject {
    @objc let title: String?
    @objc var subtitle: String?
    @objc let coordinate: CLLocationCoordinate2D
    let directions: String?
    let imageURL: URL?
    var image: UIImage?
    let recognized: Bool
    var zmanim: [Zman]
    
    init(title: String, directions: String? = nil, imageURL: URL? = nil, image: UIImage? = nil, coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0), recognized: Bool = true, zmanim: [Zman] = []) {
        self.title = title
        self.directions = directions
        self.imageURL = imageURL
        self.image = image
        self.coordinate = coordinate
        self.recognized = recognized
        self.zmanim = zmanim
    }
}

extension Location: MKAnnotation {
    @objc override var description: String {
        return "title: \(title)"
    }
}

class LocalZman {
    let title: String
    let date: Date
    var next: Bool
    
    init(title: String, date: Date, next: Bool = false) {
        self.title = title
        self.date = date
        self.next = next
    }
}

struct Shabbos {
    let parsha: String
    let url: URL
}

// TODO: get selichos set up for holidays
struct Selichos {
    struct Time {
        var title: String
        var time: String
    }
    var location: Location
    var times: [Time]
}
