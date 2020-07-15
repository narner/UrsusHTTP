//
//  PatParser.swift
//  Alamofire
//
//  Created by Daniel Clelland on 26/06/20.
//

import Foundation
import Parity

public enum PhoneticBaseParserError: Error {
    
    case invalidPrefix(String)
    case invalidSuffix(String)
    
}

public struct PhoneticBaseParser {

    public enum Padding {
        
        case padding
        case noPadding
        
        internal func shouldPad(bytes: [UInt8]) -> Bool {
            switch self {
            case .noPadding:
                return bytes.count == 0
            case .padding:
                return bytes.count == 0 || (bytes.count.isOdd && bytes.count > 2)
            }
        }
        
        internal func pad(bytes: [UInt8]) -> [UInt8] {
            if shouldPad(bytes: bytes) {
                return [0] + bytes
            } else {
                return bytes
            }
        }
        
    }

    public enum Spacing {
        
        case longSpacing
        case shortSpacing
        
        internal var dash: String {
            switch self {
            case .longSpacing:
                return "--"
            case .shortSpacing:
                return "-"
            }
        }
        
    }
    
}

extension PhoneticBaseParser {

    public static func parse(_ string: String) throws -> [UInt8] {
        let syllables = string.replacingOccurrences(of: "[\\^~-]", with: "", options: .regularExpression).chunked(by: 3)
        return try syllables.reversed().enumerated().reduce([]) { result, element in
            let (index, syllable) = element
            switch index.parity {
            case .even:
                return [try PhoneticBaseSuffix.byte(forSuffix: syllable)] + result
            case .odd:
                return [try PhoneticBasePrefix.byte(forPrefix: syllable)] + result
            }
        }
    }

    public static func render(bytes: [UInt8], padding: Padding, spacing: Spacing) -> String {
        return padding.pad(bytes: bytes).reversed().enumerated().reduce("") { result, element in
            let (index, byte) = element
            let syllable: String = {
                switch index.parity {
                case .even:
                    return PhoneticBaseSuffix.suffix(forByte: byte)
                case .odd:
                    return PhoneticBasePrefix.prefix(forByte: byte)
                }
            }()
            
            let glue: String = {
                guard index.isMultiple(of: 8) == false else {
                    return index == 0 ? "" : spacing.dash
                }
                
                switch index.parity {
                case .even:
                    return "-"
                case .odd:
                    return ""
                }
            }()
            
            return syllable + glue + result
        }
    }
    
}
