//
//  PokeEvent.swift
//  Ursus
//
//  Created by Daniel Clelland on 10/06/20.
//

import Foundation

public enum PokeError: Error {
    
    case response(String)
    case disconnection(Int?, Bool?, NSError?)
    
}

public enum PokeEvent {
    
    case success
    case failure(PokeError)
    
}
