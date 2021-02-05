//
//  ClientLoginResponseSerializer.swift
//  Alamofire
//
//  Created by Daniel Clelland on 23/07/20.
//

import Foundation
import Alamofire

internal struct ClientLoginResponseSerializer: ResponseSerializer {
    
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Ship {
        guard error == nil else { throw error! }
        
        guard let header = response?.value(forHTTPHeaderField: "Set-Cookie") else {
            throw ClientLoginResponseSerializerError.missingAuthenticationHeader
        }
        
        guard let name = header.split(separator: "=").first?.replacingOccurrences(of: "urbauth-", with: "") else {
            throw ClientLoginResponseSerializerError.invalidAuthenticationHeader(header)
        }
        
        return try Ship(string: name)
    }
    
}
