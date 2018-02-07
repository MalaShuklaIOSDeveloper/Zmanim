//
//  LocationImages.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2018 Natanel Niazoff. All rights reserved.
//

import Foundation
import UIKit

/// A helper type to retrieve location images.
struct LocationImages {
    static let Annex = UIImage(named: "Annex.jpg")
    static let FischelBeis = UIImage(named: "Fischel Beis.jpg")
    static let Glueck2Lobby = UIImage(named: "Glueck 2 Lobby.jpg")
    static let Glueck303 = UIImage(named: "Glueck 303.jpg")
    static let GlueckBeis = UIImage(named: "Glueck Beis.jpg")
    static let MussBeis = UIImage(named: "Muss Beis.jpg")
    static let MorgBeis = UIImage(named: "Morg Beis.jpg")
    static let MorgLounge = UIImage(named: "Morg Lounge.jpg")
    static let RubinShul = UIImage(named: "Rubin Shul.jpg")
    static let SefardiBeitMidrash = UIImage(named: "Sefardi Beit Midrash.jpg")
    static let SkyCaf = UIImage(named: "Sky Caf.jpg")
    static let Zysman101 = UIImage(named:"Zysman 101.jpg")
    
    static func locationImage(for title: String) -> UIImage? {
        switch title {
        case "Annex":
            return Annex
        case "Fischel Beis":
            return FischelBeis
        case "Glueck 2 Lobby":
            return Glueck2Lobby
        case "Glueck 303":
            return Glueck303
        case "Glueck Beis":
            return GlueckBeis
        case "Muss Beis":
            return MussBeis
        case "Morg Beis":
            return MorgBeis
        case "Morg Lounge":
            return MorgLounge
        case "Rubin Shul":
            return RubinShul
        case "Sefardi Beit Midrash":
            return SefardiBeitMidrash
        case "Sky Caf":
            return SkyCaf
        case "Zysman 101":
            return Zysman101
        default:
            return nil
        }
    }
}
