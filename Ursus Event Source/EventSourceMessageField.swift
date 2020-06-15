//
//  EventSourceMessageField.swift
//  Alamofire
//
//  Created by Daniel Clelland on 15/06/20.
//

import Foundation

internal enum EventSourceMessageField {
    
    case event(String)
    case id(String)
    case data(String)
    case retry(String)
    
    internal init?(parsing string: String) {
        let scanner = Scanner(string: string)
        let key = scanner.scanUpToString(":")
        _ = scanner.scanString(":")
        let value = scanner.scanUpToString("\n") ?? ""
        switch key {
        case "event":
            self = .event(value)
        case "id":
            self = .id(value)
        case "data":
            self = .data(value)
        case "retry":
            self = .retry(value)
        default:
            return nil
        }
    }
    
}
