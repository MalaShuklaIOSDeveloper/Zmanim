//
//  LocalZman.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/5/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

/// A type that represents a local zmanim time 🕰.
class LocalZman: Decodable {
    /// The title of the local zman.
    let title: String
    /// The date of the local zman.
    let date: Date
    
    init(title: String, date: Date) {
        self.title = title
        self.date = date
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        
        // Setup date formatter and init `date`.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
        let dateString = try container.decode(String.self, forKey: .time)
        guard let date = dateFormatter.date(from: dateString) else {
            throw DecodeError.notEnoughData
        }
        self.date = date
    }
}

extension LocalZman {
    enum CodingKeys: String, CodingKey {
        case title = "name"
        case time
    }
    
    /// A type that represents user info to pass to a decoder.
    struct CodingUserInfo {
        static let key = CodingUserInfoKey(rawValue: "localZmanCodingOptions")!
        let date: Date
    }
    
    /// A decoder error.
    enum DecodeError: Error {
        case notEnoughData
    }
}
