//
//  PatQ.swift
//  Alamofire
//
//  Created by Daniel Clelland on 27/06/20.
//

import Foundation
import BigInt

public struct PatQ {
    
    internal var value: BigUInt

    internal init(_ value: BigUInt) {
        self.value = value
    }

    public init() {
        self.value = .zero
    }
    
    public init(string: String) throws {
        let bytes = try parse(string)
        self.init(BigUInt(Data(bytes)))
    }
    
}

extension PatQ: CustomStringConvertible {
    
    public var description: String {
        let bytes: [UInt8] = Array(value.serialize())
        return render(bytes: bytes, padding: .noPadding, spacing: .shortSpacing)
    }
    
}

extension PatQ: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return ".~" + description
    }
    
}

extension PatQ: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: BigUInt.IntegerLiteralType) {
        self.init(BigUInt(integerLiteral: value))
    }
    
}

extension PatQ: ExpressibleByStringLiteral {
    
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

extension PatQ: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(string: try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
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
