//
//  Ursus.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Alamofire
import AlamofireLogger
import AlamofireObjectMapper
import ObjectMapper
import PromiseKit

struct Ursus {
    
    static var baseURL: String = "https://hidret-matped.urbit.org"
    
    // MARK: - Requests
    
    static func GETAuth() -> Promise<Auth> {
        return request(.GET, "/~/auth.json")
    }
    
    static func PUTAuth(oryx oryx: String, ship: String, code: String) -> Promise<Auth> {
        return request(.POST, "/~/auth.json?PUT", parameters: [
            "oryx": oryx,
            "ship": ship,
            "code": code
            ])
    }
    
    static func DELETEAuth(oryx oryx: String, ship: String) -> Promise<Auth> {
        return request(.POST, "/~/auth.json?DELETE", parameters: [
            "oryx": oryx,
            "ship": ship
            ])
    }
    
    // MARK: - Promise wrapper
    
    static func request<T: Mappable>(method: Alamofire.Method, _ path: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil) -> Promise<T> {
        let URLString = "\(self.baseURL)\(path)"
        
        return Promise { fulfill, reject in
            Alamofire.request(method, URLString, parameters: parameters, encoding: .JSON).log(level: .Verbose).responseObject { (response: Response<T, NSError>) in
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
