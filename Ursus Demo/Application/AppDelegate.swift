//
//  AppDelegate.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import UIKit
import Ursus
import AlamofireNetworkActivityIndicator

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
        
        // Uncomment this and set it to your planet's url, e.g. `"https://pittyp-pittyp.urbit.org"`
        Ursus.baseURL = "https://hidret-matped.urbit.org"
        
        return true
    }

}

