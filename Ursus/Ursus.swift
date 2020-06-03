//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/06/20.
//

import Foundation
import Combine

public class Ursus {
    
    public var url: URL
    
    public var code: String
    
    private var session = URLSession.shared
    
    private var encoder = JSONEncoder()
    
    private var decoder = JSONDecoder()
    
    public init(url: URL, code: String) {
        self.url = url
        self.code = code
    }
    
}

extension Ursus {
    
    public func connect() -> URLSession.DataTaskPublisher {
        var request = URLRequest(url: url.appendingPathComponent("/~/login"))
        request.httpMethod = "POST"
        request.httpBody = try! encoder.encode(["password": code])
        return session.dataTaskPublisher(for: request)
    }
    
}
