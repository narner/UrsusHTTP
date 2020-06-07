//
//  AckRequest.swift
//  Alamofire
//
//  Created by Daniel Clelland on 7/06/20.
//

import Foundation

struct AckRequest: Encodable {
    
    var action: String = "ack"
    var eventID: Int
    
    enum CodingKeys: String, CodingKey {
        case action
        case eventID = "event-id"
    }
    
}
