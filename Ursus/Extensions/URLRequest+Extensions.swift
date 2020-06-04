//
//  URLRequest+Extensions.swift
//  IKEventSource
//
//  Created by Daniel Clelland on 4/06/20.
//

import Foundation

extension URLRequest {
    
    init(url: URL, headers: [String: String]? = nil, method: String? = nil, body: Data? = nil) {
        self.init(url: url)
        self.allHTTPHeaderFields = headers
        self.httpMethod = method
        self.httpBody = body
    }
    
}
