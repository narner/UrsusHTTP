//
//  DeleteRequest.swift
//  Alamofire
//
//  Created by Daniel Clelland on 7/06/20.
//

import Foundation

struct DeleteRequest: Encodable {
    
    var action: String = "delete"
    
    enum CodingKeys: String, CodingKey {
        case action
    }
    
}
