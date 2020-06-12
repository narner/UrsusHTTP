//
//  AppDelegate.swift
//  Ursus Demo
//
//  Created by Daniel Clelland on 3/06/20.
//  Copyright © 2020 Protonome. All rights reserved.
//

import UIKit
import Ursus
import AlamofireLogger

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let ursus = Ursus(url: URL(string: "http://192.168.1.65")!, code: "namwes-boster-dalryt-rosfeb")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ursus.authenticationRequest().log(.verbose).response { response in
            self.ursus.subscribeRequest(
                ship: "lapred-pandel-polnet-sorwed--bacbep-labmul-tolmes-marzod",
                app: "chat-view",
                path: "/primary",
                handler: { event in
                    print("Subscribe event:", event)
                }
            ).log(.verbose)
        }
        
        return true
    }

}

struct Message: Encodable {
    
    var path: String
    var envelope: Envelope
    
}

struct Envelope: Encodable {
    
    var uid: String
    var number: Int
    var author: String
    var when: Int
    var letter: [String: String]
    
}
