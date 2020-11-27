//
//  DecodingError+Extensions.swift
//  
//
//  Created by Daniel Clelland on 27/11/20.
//

import Foundation

extension DecodingError {
    
    public static func dataCorruptedError<C>(_ type: Any.Type, at codingPath: [CodingKey], in container: C) -> DecodingError where C : KeyedDecodingContainerProtocol {
        return DecodingError.dataCorrupted(Context(codingPath: codingPath, debugDescription: "Failed to decode \(type); available keys: \(container.allKeys)"))
    }
    
}
