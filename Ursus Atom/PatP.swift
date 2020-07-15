//
//  PatP.swift
//  Alamofire
//
//  Created by Daniel Clelland on 27/06/20.
//

import Foundation
import BigInt

public struct PatP: Aura, Codable {
    
    internal var atom: BigUInt

    internal init(_ atom: BigUInt) {
        self.atom = atom
    }
    
}

extension PatP {
    
    public enum Title {
        
        case galaxy
        case star
        case planet
        case moon
        case comet
        
    }
    
    public var title: Title {
        switch bitWidth {
        case 0...8:
            return .galaxy
        case 9...16:
            return .star
        case 17...32:
            return .planet
        case 33...64:
            return .moon
        default:
            return .comet
        }
    }
    
}

extension PatP {
    
    public init(syllables: [PhoneticBaseSyllable]) {
        let bytes = syllables.map(\.byte)
        let deobfuscatedAtom = PhoneticBaseObfuscator.deobfuscate(BigUInt(Data(bytes)))
        self.init(deobfuscatedAtom)
    }
    
    public var syllables: [PhoneticBaseSyllable] {
        let obfuscatedAtom = PhoneticBaseObfuscator.obfuscate(atom)
        let bytes = obfuscatedAtom.serialize()
        let syllables: [PhoneticBaseSyllable] = bytes.reversed().enumerated().reduce([]) { result, element in
            let (index, byte) = element
            switch index.parity {
            case .even:
                return [.suffix(byte: byte)] + result
            case .odd:
                return [.prefix(byte: byte)] + result
            }
        }
        
        switch syllables.count {
        case 0:
            return [.suffix(byte: 0)]
        case 1:
            return syllables
        case 2... where syllables.count.isOdd:
            return [.prefix(byte: 0)] + syllables
        default:
            return syllables
        }
    }
    
}

extension PatP {
    
    public init(string: String) throws {
        self.init(syllables: try PhoneticBaseParser.parse(string))
    }
    
    public var string: String {
        return PhoneticBaseParser.render(syllables: syllables, spacing: .longSpacing)
    }
    
}

extension PatP: RawRepresentable {
    
    public init?(rawValue: String) {
        try? self.init(string: rawValue)
    }
    
    public var rawValue: String {
        return string
    }
    
}

extension PatP: CustomStringConvertible {
    
    public var description: String {
        return string
    }
    
}

extension PatP: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "~" + string
    }
    
}

extension PatP: ExpressibleByStringLiteral {
    
    public init(unicodeScalarLiteral value: String.ExtendedGraphemeClusterLiteralType) {
        try! self.init(string: String(unicodeScalarLiteral: value))
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        try! self.init(string: String(extendedGraphemeClusterLiteral: value))
    }

    public init(stringLiteral value: StringLiteralType) {
        try! self.init(string: String(stringLiteral: value))
    }
    
}
