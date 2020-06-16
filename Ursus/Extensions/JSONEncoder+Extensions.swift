//
//  JSONEncoder+Extensions.swift
//  Alamofire
//
//  Created by Daniel Clelland on 16/06/20.
//

import Foundation

extension JSONEncoder {
    
    public static var ursusEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }
    
}
