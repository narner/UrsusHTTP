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
        
        
        cancellable = ursus.connect()
//        .map(\.data)
//        .compactMap { data in
//            return String(data: data, encoding: .utf8)
//        }
        .sink(
            receiveCompletion: { completion in
                print(completion)
            },
            receiveValue: { value in
                print(value)
            }
        )
        
        return true
    }

}
