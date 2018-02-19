//
//  LocationImages.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

/// A helper type to retrieve location images 🏙.
struct LocationImages {
    static let Annex = UIImage(named: Location.Title.annex.fileName)
    static let FischelBeis = UIImage(named: Location.Title.fischelBeis.fileName)
    static let Glueck2Lobby = UIImage(named: Location.Title.glueck2Lobby.fileName)
    static let Glueck303 = UIImage(named: Location.Title.glueck303.fileName)
    static let GlueckBeis = UIImage(named: Location.Title.glueckBeis.fileName)
    static let MussBeis = UIImage(named: Location.Title.mussBeis.fileName)
    static let MorgBeis = UIImage(named: Location.Title.morgBeis.fileName)
    static let MorgLounge = UIImage(named: Location.Title.morgLounge.fileName)
    static let RubinShul = UIImage(named: Location.Title.rubinShul.fileName)
    static let SefardiBeitMidrash = UIImage(named: Location.Title.sefardiBeitMidrash.fileName)
    static let SkyCaf = UIImage(named: Location.Title.skyCaf.fileName)
    static let Zysman101 = UIImage(named: Location.Title.zysman101.fileName)

    static func image(forLocationTitle title: String) -> UIImage? {
        if let locationTitle = Location.Title(rawValue: title) {
            switch locationTitle {
            case .annex:
                return Annex
            case .fischelBeis:
                return FischelBeis
            case .glueck2Lobby:
                return Glueck2Lobby
            case .glueck303:
                return Glueck303
            case .glueckBeis:
                return GlueckBeis
            case .mussBeis:
                return MussBeis
            case .morgBeis:
                return MorgBeis
            case .morgLounge:
                return MorgLounge
            case .rubinShul:
                return RubinShul
            case .sefardiBeitMidrash:
                return SefardiBeitMidrash
            case .skyCaf:
                return SkyCaf
            case .zysman101:
                return Zysman101
            }
        }
        return nil
    }
}

extension Location.Title {
    var localImageURL: URL? {
        return Bundle.main.url(forResource: rawValue, withExtension: ".jpg")
    }
}

fileprivate extension Location.Title {
    var fileName: String {
        return rawValue + ".jpg"
    }
}
