//
//  Ack.swift
//  IKEventSource
//
//  Created by Daniel Clelland on 4/06/20.
//

import Foundation

struct Ack<JSON: Encodable>: Encodable {
    
    #warning("Note that this needs to be an array with two json objects")
    
    var action: String = "ack"
    // [{action: "ack", "event-id": parseInt(this.lastEventId)}, j]
    var json: JSON
    
}
