//
//  PatP+Extensions.swift
//  Alamofire
//
//  Created by Daniel Clelland on 26/06/20.
//

import Foundation
import BigInt

extension PatP: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: BigUInt.IntegerLiteralType) {
        self.init(BigUInt(integerLiteral: value))
    }
    
}

extension PatP: ExpressibleByStringLiteral {
    
    #warning("Convert PatP ExpressibleByStringLiteral implementation to use the phonetic base")
    
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(BigInt(unicodeScalarLiteral: value))
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(BigInt(extendedGraphemeClusterLiteral: value))
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(BigInt(stringLiteral: value))
    }
    
}

extension PatP: CustomStringConvertible {
    
    #warning("Convert PatP CustomStringConvertible functions to use the phonetic base")
    
    public var description: String {
        return value.description
    }
    
}

extension PatP: Codable {
    
    #warning("Convert PatP Codable functions to use the phonetic base")
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(try container.decode(BigUInt.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(value)
    }
    
}

extension PatP: Equatable {
    
    public static func == (lhs: PatP, rhs: PatP) -> Bool {
        return lhs.value == rhs.value
    }
    
}

extension PatP: Comparable {
    
    public static func < (lhs: PatP, rhs: PatP) -> Bool {
        return lhs.value < rhs.value
    }
    
}

extension PatP: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
}

extension PatP: Strideable {
    
    public func advanced(by n: BigInt) -> PatP {
        return PatP(value.advanced(by: n))
    }
    
    public func distance(to other: PatP) -> BigInt {
        return value.distance(to: other.value)
    }
    
}

extension PatP: UnsignedInteger {
    
    public typealias Words = BigUInt.Words
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(BigUInt(source))
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.init(BigUInt(source))
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        guard let value = BigUInt(exactly: source) else {
            return nil
        }

        self.init(value)
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = BigUInt(exactly: source) else {
            return nil
        }
        
        self.init(value)
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(BigUInt(clamping: source))
    }

    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.init(BigUInt(truncatingIfNeeded: source))
    }
    
    public var bitWidth: Int {
        return value.bitWidth
    }
    
    public var trailingZeroBitCount: Int {
        return value.trailingZeroBitCount
    }
    
    public var words: BigUInt.Words {
        return value.words
    }
    
    public static var isSigned: Bool {
        return BigUInt.isSigned
    }
    
    public static func % (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value % rhs.value)
    }
    
    public static func %= (lhs: inout PatP, rhs: PatP) {
        lhs = lhs % rhs
    }
    
    public static func & (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value & rhs.value)
    }
    
    public static func &= (lhs: inout PatP, rhs: PatP) {
        lhs = lhs & rhs
    }
    
    public static func * (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value * rhs.value)
    }
    
    public static func *= (lhs: inout PatP, rhs: PatP) {
        lhs = lhs * rhs
    }
    
    public static func + (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value + rhs.value)
    }
    
    public static func += (lhs: inout PatP, rhs: PatP) {
        lhs = lhs + rhs
    }
    
    public static func - (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value - rhs.value)
    }
    
    public static func -= (lhs: inout PatP, rhs: PatP) {
        lhs = lhs - rhs
    }
    
    public static func / (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value / rhs.value)
    }
    
    public static func /= (lhs: inout PatP, rhs: PatP) {
        lhs = lhs / rhs
    }
    
    public static func << <RHS>(lhs: PatP, rhs: RHS) -> PatP where RHS : BinaryInteger {
        return PatP(lhs.value << rhs)
    }
    
    public static func <<= <RHS>(lhs: inout PatP, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs << rhs
    }
    
    public static func >> <RHS>(lhs: PatP, rhs: RHS) -> PatP where RHS : BinaryInteger {
        return PatP(lhs.value >> rhs)
    }
    
    public static func >>= <RHS>(lhs: inout PatP, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs >> rhs
    }
    
    public static func ^ (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value ^ rhs.value)
    }
    
    public static func ^= (lhs: inout PatP, rhs: PatP) {
        lhs = lhs ^ rhs
    }
    
    public static func | (lhs: PatP, rhs: PatP) -> PatP {
        return PatP(lhs.value | rhs.value)
    }
    
    public static func |= (lhs: inout PatP, rhs: PatP) {
        lhs = lhs | rhs
    }
    
    public static prefix func ~ (x: PatP) -> PatP {
        return PatP(~x.value)
    }

}
