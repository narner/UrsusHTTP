//
//  String+Extensions.swift
//  Alamofire
//
//  Created by Daniel Clelland on 12/06/20.
//

import Foundation
import BigInt

extension UUID {
    
    public var base32String: String {
        let bytes = [uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.6, uuid.7, uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15]
        return BigUInt(Data(bytes)).base32String
    }
    
}

extension BinaryInteger {
    
    internal var base32String: String {
        return "0v" + String(self, radix: 32, chunk: 5)
    }
    
}

extension String {
    
    internal init<T: BinaryInteger>(_ value: T, radix: Int = 10, chunk: Int, separator: String = ".") {
        self = String(String(value, radix: radix).reversed().chunked(by: chunk).joined(separator: separator).reversed())
    }
    
}
