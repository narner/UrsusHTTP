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
    
    var symbols: [Symbol] {
        return ship.syllables.map { syllable in
            return syllable.symbol
        }
    }
    
}

extension PhoneticBaseSyllable {
    
    var symbol: Symbol {
        return Symbol.all[self.rawValue]!
    }
    
}
