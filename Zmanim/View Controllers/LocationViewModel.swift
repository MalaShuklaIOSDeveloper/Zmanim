//
//  LocationViewModel.swift
//  Zmanim
//
//  Created by Natanel Niazoff on 2/8/18.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation

struct LocationViewModelData {
    let location: Location
}

enum LocationItemKey {
    case description, zman
}

enum LocationCellIdentifier: String {
    case descriptionCell, zmanCell
}

protocol LocationItem {
    var key: LocationItemKey { get }
    var cellIdentifier: LocationCellIdentifier { get }
}

class LocationViewModel {
    let location: Location
    let items: [Int : [LocationItem]]
    
    var numberOfSections: Int {
        return items.count
    }
    
    init(data: LocationViewModelData) {
        self.location = data.location
        
        var items: [Int : [LocationItem]] = [
            0 : [DescriptionLocationItem(text: location.directions!)],
            1 : []
        ]
        for zman in location.zmanim {
            items[1]?.append(ZmanLocationItem(zman: zman))
        }
        self.items = items
    }
    
    func numberOfRows(in section: Int) -> Int {
        return items[section]?.count ?? 0
    }
    
    func item(for indexPath: IndexPath) -> LocationItem? {
        return items[indexPath.section]?[indexPath.row]
    }
    
    func title(for section: Int) -> String? {
        switch section {
        case 0: return "Description"
        case 1:
            if let zmanim = items[1] {
                if !zmanim.isEmpty {
                    return "Today's Schedule"
                }
            }
        default: return nil
        }
        return nil
    }
}

struct DescriptionLocationItem: LocationItem {
    let key: LocationItemKey = .description
    let cellIdentifier: LocationCellIdentifier = .descriptionCell
    let text: String
}

struct ZmanLocationItem: LocationItem {
    let key: LocationItemKey = .zman
    let cellIdentifier: LocationCellIdentifier = .zmanCell
    let zman: Zman
}

struct LocationHeader {
    let index: Int
    let title: String
}
