//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import PromiseKit

struct Ursus {
    
    static var baseURL: String = "https://hidret-matped.urbit.org"
    
    static var appl = ""
    static var ship = "~hidret-matped"
    static var code = ""
    static var oryx = ""
    
    // MARK: - Singleton
    
    static func GETAuth() -> Promise<Auth> {
        return GET("/~/auth")
    }
    
    // MARK: - Requests
    
    static func GET<T: Mappable>(path: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil) -> Promise<T> {
        let URLString = "\(self.baseURL)\(path).json"
        
        return Promise { fulfill, reject in
            Alamofire.request(.GET, URLString, parameters: parameters).responseObject { (response: Response<T, NSError>) in
                switch response.result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }
    
}
