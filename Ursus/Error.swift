//
//  Error.swift
//  Ursus
//
//  Created by Daniel Clelland on 9/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Foundation

/// Convenience struct for creating `NSError` objects.
public struct Error {
    
    /// Ursus error domain.
    public static let domain = "com.protonome.Ursus"
    
    /// Ursus error codes.
    public enum Code: Int {
        
        /// Ack request returned `++mean-json`.
        case AckFail = -40001
        
    }
    
    /// Generates an Ursus error object.
    internal static func error(code: Code, failureReason: String? = nil) -> NSError {
        var userInfo = [NSObject : AnyObject]()
        userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        return NSError(domain: domain, code: code.rawValue, userInfo: userInfo)
    }

}