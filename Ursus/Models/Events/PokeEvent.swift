//
//  PokeEvent.swift
//  Ursus
//
//  Created by Daniel Clelland on 10/06/20.
//

import Foundation

public enum PokeEvent<Failure: Error> {
    
    case finished
    case failure(Failure)
    
}
