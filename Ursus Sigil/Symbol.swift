//
//  Symbol.swift
//  Alamofire
//
//  Created by Daniel Clelland on 14/07/20.
//

import Foundation
import SwiftSVG
//import XMLDocument

internal struct Symbol: Decodable {
    
    internal static var all: [String: Symbol] = {
        let bundle = Bundle(identifier: "org.cocoapods.Ursus")!
        let url = bundle .url(forResource: "index", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode([String: Symbol].self, from: data)
    }()
    
    var name: String
    var attributes: [String: String]
    var children: [Symbol]
    
}

extension Symbol {
    
    var wrappedElement: String {
        return "<svg viewBox=\"0 0 128 128\">\(element)</svg>"
    }
    
    var element: String {
        let modifiedAttributes: [String: String] = Dictionary(
            uniqueKeysWithValues: attributes.map { key, value in
                switch (key, value) {
                case ("fill", "@BG"):
                    return (key, "#FFFFFF")
                case ("fill", "@FG"):
                    return (key, "#000000")
                case ("stroke", "@BG"):
                    return (key, "#FFFFFF")
                case ("stroke", "@FG"):
                    return (key, "#000000")
                default:
                    return (key, value)
                }
            }
        )
        
        return "<\(name) \(modifiedAttributes.map { "\($0)=\"\($1)\"" }.joined(separator: " "))>\(children.map(\.element).joined())</\(name)>"
    }
    
}
