//
//  PhoneticBaseSyllable.swift
//  Alamofire
//
//  Created by Daniel Clelland on 15/07/20.
//

import Foundation

public enum PhoneticBaseSyllable: RawRepresentable, CaseIterable {
    
    case prefix(PhoneticBasePrefix)
    case suffix(PhoneticBaseSuffix)
    
    public init?(rawValue: String) {
        switch (PhoneticBasePrefix(rawValue: rawValue), PhoneticBaseSuffix(rawValue: rawValue)) {
        case (.some(let prefix), .none):
            self = .prefix(prefix)
        case (.none, .some(let suffix)):
            self = .suffix(suffix)
        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .prefix(let prefix):
            return prefix.rawValue
        case .suffix(let suffix):
            return suffix.rawValue
        }
    }
    
    public static var allCases: [PhoneticBaseSyllable] {
        let prefixes = PhoneticBasePrefix.allCases.map { prefix in
            return PhoneticBaseSyllable.prefix(prefix)
        }
        
        let suffixes = PhoneticBaseSuffix.allCases.map { suffix in
            return PhoneticBaseSyllable.suffix(suffix)
        }
        
        return prefixes + suffixes
    }
    
}
