//
//  PokeEvent.swift
//  Ursus
//
//  Created by Daniel Clelland on 10/06/20.
//

import Foundation
import Alamofire

public enum PokeEvent {

    public enum Error: Swift.Error {
        
        case request(AFError)
        case response(String)
        case disconnection(Int?, Bool?, NSError?)
        
    }
    
    case success
    case failure(Error)
    
}
