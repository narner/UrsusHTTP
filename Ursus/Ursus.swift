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

// See http://urbit.org/docs/arvo/internals/eyre/specification/#-1-3-authentication

extension Ursus {
    
    /**
     Fetches an authentication object.
     
     - returns: A promise for an `Auth` object.
     */
    public static func GETAuth() -> Promise<Auth> {
        return request(.GET, "/~/auth.json").promiseObject()
    }
    
    /**
     Authorize a given user.
     
     - oryx: A unique CSRF token. Can be acquired from the results of `GETAuth`.
     - ship: The ship's name, e.g.: `"pittyp-pittyp"`
     - code: The ship's authentication code. Can be printed in dojo using `+code`.
     
     - returns: A promise for an `Auth` object.
     */
    public static func PUTAuth(oryx oryx: String, ship: String, code: String) -> Promise<Auth> {
        let parameters = [
            "oryx": oryx,
            "ship": ship,
            "code": code
        ]
        
        return request(.POST, "/~/auth.json?PUT", parameters: parameters).promiseObject()
    }
    
    /**
     Revoke authorization for a given user.
     
     - oryx: The CSRF token. Can be acquired from the results of `GETAuth`.
     - ship: The ship's name, e.g.: `"pittyp-pittyp"`
     
     - returns: A promise for a `Ack` object.
     */
    public static func DELETEAuth(oryx oryx: String, ship: String) -> Promise<Void> {
        let parameters = [
            "oryx": oryx,
            "ship": ship
        ]
        
        return request(.POST, "/~/auth.json?DELETE", parameters: parameters).promise()
    }

}

// MARK: - Messaging

// See http://urbit.org/docs/arvo/internals/eyre/specification/#-1-4-messaging

extension Ursus {
    
    /**
     Posts a message to an Urbit application.
     
     - appl: The application
     - mark: The application's mark
     - oryx: The CSRF token. Can be acquired from the results of `GETAuth`.
     - wire: The path, e.g. `"/"`
     - xyro: Data which will be converted to the `mark`.
     
     - returns: A promise for a `Ack` object.
     */
    public static func POSTTo(appl appl: String, mark: String, oryx: String, wire: String, xyro: String) -> Promise<Void> {
        let parameters = [
            "oryx": oryx,
            "wire": wire,
            "xyro": xyro
        ]
        
        return request(.POST, "/~/to/\(appl)/\(mark).json", parameters: parameters).promise()
    }
    
}

// MARK: - Requests

extension Ursus {
    
    /**
     Creates an HTTP request to a path on `baseURL`.
     
     - method: The HTTP method.
     - path: The URL path, to be appended to `baseURL`.
     - parameters: The parameters. Sent up as JSON. `nil` by default.
     
     - returns: An HTTP request.
     */
    public static func request(method: Alamofire.Method, _ path: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil) -> Request {
        guard let baseURL = baseURL else {
            fatalError("Please set `Ursus.baseURL` to the URL your ship is being served on.")
        }
        
        return Alamofire.request(method, "\(baseURL)\(path)", parameters: parameters, encoding: .JSON)
    }
    
}

// MARK: - Promises

extension Request {
    
    /**
     Wraps an HTTP request in a promise, checking the response contents for an error case.
     
     - returns: An empty promise.
     */
    public func promise() -> Promise<Void> {
        return promiseObject().then { (ack: Ack) -> Void in
            if ack.ok == false {
                throw Error.error(.AckFail, failureReason: ack.description)
            }
        }
    }
    
    /**
     Wraps an HTTP request in a promise of type `Promise<T>` where `T` conforms to `Mappable`.
     
     - returns: A promise for an ObjectMapper object.
     */
    public func promiseObject<T: Mappable>() -> Promise<T> {
        return Promise { fulfill, reject in
            self.responseObject { (response: Response<T, NSError>) in
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
