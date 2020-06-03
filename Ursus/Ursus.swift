//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation

public struct Ursus {
    
    public var url: URL
    
    public var code: String
    
    public var session: URLSession = .shared
    
    public init(url: URL, code: String) {
        self.url = url
        self.code = code
    }
    
}
