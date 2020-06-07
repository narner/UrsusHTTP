//
//  SubscribeResponse.swift
//  Ursus
//
//  Created by Daniel Clelland on 7/06/20.
//

import Foundation

enum SubscribeResponse: Decodable {

    case success(id: Int)
    case failure(id: Int, error: String)
    
    enum CodingKeys: String, CodingKey {
        case id
        case okay = "ok"
        case error = "err"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch container.allKeys {
        case [.id, .okay]:
            self = .success(
                id: try container.decode(Int.self, forKey: .id)
            )
        case [.id, .error]:
            self = .failure(
                id: try container.decode(Int.self, forKey: .id),
                error: try container.decode(String.self, forKey: .error)
            )
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to decode \(type(of: self)); available keys: \(container.allKeys)"))
        }
    }
    
}
