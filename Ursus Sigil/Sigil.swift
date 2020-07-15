//
//  Sigil.swift
//  Ursus Sigil
//
//  Created by Daniel Clelland on 10/07/20.
//

import Foundation

public struct Sigil {
    
    public var ship: Ship
    
    public init(ship: Ship) {
        self.ship = ship
    }
    
}

extension Sigil {
    
    var symbol: Symbol {
        let syllables = ship.description.replacingOccurrences(of: "[\\^~-]", with: "", options: .regularExpression).chunked(by: 3)
        return Symbol.all[syllables.first!]!
    }
    
}
