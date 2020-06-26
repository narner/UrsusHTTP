//
//  PatQ+Extensions.swift
//  Alamofire
//
//  Created by Daniel Clelland on 26/06/20.
//

import Foundation
import BigInt

extension PatQ: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: BigUInt.IntegerLiteralType) {
        self.init(BigUInt(integerLiteral: value))
    }
    
}

extension PatQ: ExpressibleByStringLiteral {
    
    #warning("Convert PatQ ExpressibleByStringLiteral implementation to use the phonetic base")
    
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

extension PatQ: CustomStringConvertible {
    
    #warning("Convert PatQ CustomStringConvertible functions to use the phonetic base")
    
    public var description: String {
        return value.description
    }
    
}

extension PatQ: Codable {
    
    #warning("Convert PatQ Codable functions to use the phonetic base")
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(try container.decode(BigUInt.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(value)
    }
    
}

extension PatQ: Equatable {
    
    public static func == (lhs: PatQ, rhs: PatQ) -> Bool {
        return lhs.value == rhs.value
    }
    
}

extension PatQ: Comparable {
    
    public static func < (lhs: PatQ, rhs: PatQ) -> Bool {
        return lhs.value < rhs.value
    }
    
}

extension PatQ: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
}

extension PatQ: Strideable {
    
    public func advanced(by n: BigInt) -> PatQ {
        return PatQ(value.advanced(by: n))
    }
    
    public func distance(to other: PatQ) -> BigInt {
        return value.distance(to: other.value)
    }
    
}

extension PatQ: UnsignedInteger {
    
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
    
    public static func % (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value % rhs.value)
    }
    
    public static func %= (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs % rhs
    }
    
    public static func & (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value & rhs.value)
    }
    
    public static func &= (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs & rhs
    }
    
    public static func * (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value * rhs.value)
    }
    
    public static func *= (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs * rhs
    }
    
    public static func + (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value + rhs.value)
    }
    
    public static func += (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs + rhs
    }
    
    public static func - (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value - rhs.value)
    }
    
    public static func -= (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs - rhs
    }
    
    public static func / (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value / rhs.value)
    }
    
    public static func /= (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs / rhs
    }
    
    public static func << <RHS>(lhs: PatQ, rhs: RHS) -> PatQ where RHS : BinaryInteger {
        return PatQ(lhs.value << rhs)
    }
    
    public static func <<= <RHS>(lhs: inout PatQ, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs << rhs
    }
    
    public static func >> <RHS>(lhs: PatQ, rhs: RHS) -> PatQ where RHS : BinaryInteger {
        return PatQ(lhs.value >> rhs)
    }
    
    public static func >>= <RHS>(lhs: inout PatQ, rhs: RHS) where RHS : BinaryInteger {
        lhs = lhs >> rhs
    }
    
    public static func ^ (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value ^ rhs.value)
    }
    
    public static func ^= (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs ^ rhs
    }
    
    public static func | (lhs: PatQ, rhs: PatQ) -> PatQ {
        return PatQ(lhs.value | rhs.value)
    }
    
    public static func |= (lhs: inout PatQ, rhs: PatQ) {
        lhs = lhs | rhs
    }
    
    public static prefix func ~ (x: PatQ) -> PatQ {
        return PatQ(~x.value)
    }

}
