//
//  Credentials.swift
//  UrsusHTTP
//
//  Created by Daniel Clelland on 7/07/20.
//

import Foundation

public struct Credentials: Codable {
    
    public var url: URL
    public var code: Code
    
    public init(url: URL, code: Code) {
        self.url = url
        self.code = code
    }
    
}
