//
//  AppDelegate.swift
//  Ursus Demo
//
//  Created by Daniel Clelland on 3/06/20.
//  Copyright © 2020 Protonome. All rights reserved.
//

import UIKit
import Combine
import Ursus

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let ursus = Ursus(url: URL(string: "http://192.168.1.65")!, code: "lidlyx-dinmeg-masper-hilbex")
    
    var cancellable: AnyCancellable?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        cancellable = ursus.poke(
//            ship: "habsun-sansep-filfyr-fotpec--simlun-ticrus-matzod-marzod",
//            app: "chat-store",
//            mark: "json",
//            json: ["test": 123]
//        )
        
        let uid = 1 // '0v' + '.'.join(s[i:i+5] for i in range(0, len(s), 5))[::-1]
        
//        let json: [String: AnyObject] = [
//            "message": [
//                "path": "/~/~habsun-sansep-filfyr-fotpec--simlun-ticrus-matzod-marzod/mc",
//                "envelope": [
//                    "uid": uid,
//                    "number": 1,
//                    "author": "~habsun-sansep-filfyr-fotpec--simlun-ticrus-matzod-marzod",
//                    "when": Int(Date().timeIntervalSince1970 * 1000),
//                    "letter": [
//                        "text": "hello world!"
//                    ]
//                ]
//            ]
//        ]
        
        cancellable = ursus.connect()
            .flatMap { (data, response) in
                return self.ursus.poke(
                    ship: "habsun-sansep-filfyr-fotpec--simlun-ticrus-matzod-marzod",
                    app: "chat-store",
                    mark: "json",
                    json: [String: String]()
                )
            }
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { value in
                    print(String(bytes: value.data, encoding: .utf8)!, value.response)
                }
            )
        
        return true
    }

}
