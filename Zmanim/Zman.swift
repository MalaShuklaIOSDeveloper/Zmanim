//
//  Zman.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a zman 👨‍👨‍👦 for minyan.
class Zman: Decodable {
    /// The zman's tefillah.
    let tefillah: Tefillah
    
    /// The zman's date.
    let date: Date
    
    /// The locations a zman is taking place at.
    var locations: [Location]
    
    init(tefillah: Tefillah, date: Date, locations: [Location]) {
        self.tefillah = tefillah
        self.date = date
        self.locations = locations
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Setup user info and init `tefillah`.
        guard let zmanUserInfo = decoder.userInfo[CodingUserInfo.key] as? CodingUserInfo else {
            throw DecodeError.notEnoughData
        }
        self.tefillah = zmanUserInfo.tefillah
        
        // Setup date formatter and init `date`.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateString = try container.decode(String.self, forKey: .time)
        guard let date = dateFormatter.date(from: dateString) else {
            throw DecodeError.notEnoughData
        }
        self.date = date
        
        // Init `name` and set as single unrecognized location.
        let title = try container.decode(String.self, forKey: .title)
        self.locations = [Location(title: title)]
    }
}

extension Zman {
    enum CodingKeys: String, CodingKey {
        case title = "name"
        case time
    }
    
    /// A type that represents user info to pass to a decoder.
    struct CodingUserInfo {
        static let key = CodingUserInfoKey(rawValue: "zmanCodingOptions")!
        let tefillah: Tefillah
        let date: Date
    }
    
    /// A decoder error.
    enum DecodeError: Error {
        case notEnoughData
    }
}

extension Zman: CustomStringConvertible {
    var description: String {
        return "tefillah: \(tefillah), date: \(date.description(with: Locale.current))"
    }
}

extension Zman: Equatable {
    static func ==(lhs: Zman, rhs: Zman) -> Bool {
        return lhs.tefillah == rhs.tefillah && lhs.date == rhs.date 
    }
}
