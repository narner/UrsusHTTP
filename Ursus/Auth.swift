//
//  Auth.swift
//  Ursus
//
//  Created by Daniel Clelland on 5/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Foundation
import ObjectMapper

/// An authentication response.
struct Auth {
    
    /// A list of allowed users.
    var auth: [String]?
    
    /// A hash of `oryx`, used as an insecure view identifier
    var ixor: String?
    
    /// A unique CSRF token that identifies this view
    var oryx: String?
    
    /// The parent ship
    var sein: String?
    
    /// The serving ship
    var ship: String?
    
    /// The active user
    var user: String?
    
}

extension Auth: Mappable {
    
    init?(_ map: Map) { }
    
    mutating func mapping(map: Map) {
        auth <- map["auth"]
        ixor <- map["ixor"]
        oryx <- map["oryx"]
        sein <- map["sein"]
        ship <- map["ship"]
        user <- map["user"]
    }
    
}
