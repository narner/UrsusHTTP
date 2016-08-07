//
//  Auth.swift
//  Ursus
//
//  Created by Daniel Clelland on 5/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Foundation
import ObjectMapper

/// An Urbit authentication response.
/// Not unlike the [client state](http://urbit.org/~~/docs/arvo/internals/eyre/specification/#-2-2-authentication) as mentioned in the Arvo docs, except we don't really stash it anywhere (yet).
public struct Auth {
    
    /// A list of allowed users.
    public var auth: [String]?
    
    /// A hash of `oryx`, used as an insecure view identifier
    public var ixor: String?
    
    /// A unique CSRF token that identifies this view
    public var oryx: String?
    
    /// The parent ship
    public var sein: String?
    
    /// The serving ship
    public var ship: String?
    
    /// The active user
    public var user: String?
    
}

extension Auth: Mappable {
    
    public init?(_ map: Map) { }
    
    public mutating func mapping(map: Map) {
        auth <- map["auth"]
        ixor <- map["ixor"]
        oryx <- map["oryx"]
        sein <- map["sein"]
        ship <- map["ship"]
        user <- map["user"]
    }
    
}
