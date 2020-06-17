//
//  PokeError.swift
//  Alamofire
//
//  Created by Daniel Clelland on 12/06/20.
//

import Foundation

public enum PokeError: Error {
    
    case channelRequestFailure(Error)
    case channelRequestFinished(HTTPURLResponse)
    case pokeFailure(String)
    
}
