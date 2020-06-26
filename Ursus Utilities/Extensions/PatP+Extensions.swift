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

extension PatP: Codable {
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(string: try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(description)
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
