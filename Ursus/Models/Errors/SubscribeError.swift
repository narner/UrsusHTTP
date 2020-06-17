//
//  SubscribeError.swift
//  Alamofire
//
//  Created by Daniel Clelland on 12/06/20.
//

import Foundation

public enum SubscribeError: Error {
    
    case channelRequestFailure(Error)
    case channelRequestFinished(HTTPURLResponse)
    case subscribeFailure(String)
    
}
