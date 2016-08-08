//
//  Status.swift
//  Pods
//
//  Created by Daniel Clelland on 8/08/16.
//
//

import Foundation
import ObjectMapper

/// Status response returned by some queries.
public struct Status {
    
    /// Whether or not the response was okay.
    public var ok: Bool = false
    
}

extension Status: Mappable {
    
    public init?(_ map: Map) { }
    
    public mutating func mapping(map: Map) {
        ok <- map["ok"]
    }
    
}
