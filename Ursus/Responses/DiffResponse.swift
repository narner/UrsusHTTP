//
//  DiffResponse.swift
//  Ursus
//
//  Created by Daniel Clelland on 7/06/20.
//

import Foundation

struct DiffResponse: Decodable {
    
    var id: Int
//    var json: Any
    #warning("Set up dynamic JSON decoder")
    
    enum CodingKeys: String, CodingKey {
        case id
//        case json
    }
    
}
