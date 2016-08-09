//
//  Ack.swift
//  Ursus
//
//  Created by Daniel Clelland on 9/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Foundation
import ObjectMapper

/// Response positive/negative acknowledgement. See `++nice-json` and `++mean-json` in `eyre.hoon`.
///
/// This would ideally be a Swift enum but this is easiest for now.
public struct Ack {
    
    /// Should be true when a response is positive.
    var ok: Bool = false
    
    /// Should contain an error message when a response is negative.
    var fail: String?
    
}

extension Ack: Mappable {
    
    public init?(_ map: Map) { }

    public mutating func mapping(map: Map) {
        ok <- map["ok"]
        fail <- map["fail"]
    }
    
}
