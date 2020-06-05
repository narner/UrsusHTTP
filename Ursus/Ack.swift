//
//  Ack.swift
//  IKEventSource
//
//  Created by Daniel Clelland on 4/06/20.
//

import Foundation

struct Ack: Encodable {
    
    var action: String = "ack"
    var eventID: Int
    
    enum CodingKeys: String, CodingKey {
        case action
        case eventID = "event-id"
    }
    
}
