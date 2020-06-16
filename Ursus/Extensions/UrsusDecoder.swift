//
//  UrsusDecoder.swift
//  Alamofire
//
//  Created by Daniel Clelland on 13/06/20.
//

import Foundation

public class UrsusDecoder: JSONDecoder {
    
    public override init() {
        super.init()
        self.dateDecodingStrategy = .millisecondsSince1970
        self.dataDecodingStrategy = .jsonObject
    }
    
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        userInfo[.jsonObject] = try JSONSerialization.jsonObject(with: data)
        let result = try super.decode(type, from: data)
        userInfo[.jsonObject] = nil
        return result
    }
    
}

extension JSONDecoder.DataDecodingStrategy {
    
    public static var jsonObject: JSONDecoder.DataDecodingStrategy {
        return JSONDecoder.DataDecodingStrategy.custom { decoder -> Data in
            let jsonObject: Any? = decoder.codingPath.reduce(decoder.userInfo[.jsonObject]) { result, codingKey in
                switch codingKey.intValue {
                case .some(let intValue):
                    return (result as? [Any])?[intValue]
                case .none:
                    return (result as? [String: Any])?[codingKey.stringValue]
                }
            }
            
            return try JSONSerialization.data(withJSONObject: jsonObject as Any)
        }
    }
    
}

extension CodingUserInfoKey {
    
    internal static let jsonObject = CodingUserInfoKey(rawValue: "jsonObject")!
    
}
