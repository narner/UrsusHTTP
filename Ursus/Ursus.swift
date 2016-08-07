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

/// An Urbit API client.
public struct Ursus {
    
    /**
     The base URL used to make requests. This must be set before any requests are made.
     
     At this stage, this will usually be something like `https://pittyp-pittyp.urbit.org` or `http://localhost:8080`.
     
     Easiest thing to do is to add the following line to `application(didFinishLaunchingWithOptions:)`:
     
        Ursus.baseURL = "https://planet-name.urbit.org"
     
     Don't forget, your planet will need to be online for you to send messages to it!
     */
    public static var baseURL: String?
    
}

// MARK: - Authentication

extension Ursus {
    
    /**
     Fetches an authentication object.
     
     - returns: A promise for an `Auth` object.
     */
    public static func GETAuth() -> Promise<Auth> {
        return request(.GET, "/~/auth.json")
    }
    
    /**
     Authorize a given user.
     
     - oryx: A unique CSRF token. Can be acquired from the results of `GETAuth`.
     - ship: The ship's name, e.g.: `"pittyp-pittyp"`
     - code: The ship's authentication code. Can be printed in dojo using `+code`.
     
     - returns: A promise for an `Auth` object.
     */
    public static func PUTAuth(oryx oryx: String, ship: String, code: String) -> Promise<Auth> {
        return request(.POST, "/~/auth.json?PUT", parameters: [
            "oryx": oryx,
            "ship": ship,
            "code": code
            ])
    }
    
    /**
     Revoke authorization for a given user.
     
     - oryx: A unique CSRF token. Can be acquired from the results of `GETAuth`.
     - ship: The ship's name, e.g.: `"pittyp-pittyp"`
     
     - returns: A promise for an empty `Auth` object (this needs to be revised).
     */
    public static func DELETEAuth(oryx oryx: String, ship: String) -> Promise<Auth> {
        return request(.POST, "/~/auth.json?DELETE", parameters: [
            "oryx": oryx,
            "ship": ship
            ])
    }

}

// MARK: - Request constructors

extension Ursus {
    
    /**
     Creates an HTTP request to a path on `baseURL`.
     
     - method: The HTTP method.
     - path: The URL path, to be appended to `baseURL`.
     - parameters: The parameters. Sent up as JSON. `nil` by default.
     
     - returns: A promise for an HTTP response.
     */
    public static func request<T: Mappable>(method: Alamofire.Method, _ path: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil) -> Promise<T> {
        return Promise { fulfill, reject in
            guard let baseURL = baseURL else {
                reject(Error.error(withCode: .NoBaseURLSpecified))
                return
            }
            
            Alamofire.request(method, "\(baseURL)\(path)", parameters: parameters, encoding: .JSON).responseObject { (response: Response<T, NSError>) in
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
