//
//  UnsubscribeRequest.swift
//  Alamofire
//
//  Created by Daniel Clelland on 7/06/20.
//

import Foundation

struct UnsubscribeRequest: Encodable {
    
    var id: Int
    var action: String = "unsubscribe"
    var subscription: Int
    
}
