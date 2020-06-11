//
//  SubscribeEvent.swift
//  Ursus
//
//  Created by Daniel Clelland on 10/06/20.
//

import Foundation
import Alamofire

public enum SubscribeError: Error {
    
    case request(AFError)
    case response(String)
    case disconnection(Int?, Bool?, NSError?)
    
}

public enum SubscribeEvent {
    
    case success
    case failure(SubscribeError)
    case message(Any)
    case quit
    
}
