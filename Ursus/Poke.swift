//
//  Poke.swift
//  Pods-Ursus Demo
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation

struct Poke<JSON: Encodable>: Encodable {
    
    var id: Int
    var action: String = "poke"
    var ship: String
    var app: String
    var mark: String
    var json: JSON
    
}
