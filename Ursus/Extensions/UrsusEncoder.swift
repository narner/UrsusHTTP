//
//  UrsusEncoder.swift
//  Alamofire
//
//  Created by Daniel Clelland on 16/06/20.
//

import Foundation

public class UrsusEncoder: JSONEncoder {
    
    public override init() {
        super.init()
        self.dateEncodingStrategy = .millisecondsSince1970
    }
    
}
