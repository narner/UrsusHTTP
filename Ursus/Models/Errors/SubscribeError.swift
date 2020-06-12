//
//  SubscribeError.swift
//  Alamofire
//
//  Created by Daniel Clelland on 12/06/20.
//

import Foundation
import Alamofire

public enum SubscribeError: Error {
    
    case request(AFError)
    case response(String)
    case disconnection(EventCompletion)
    
}
