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
        
//        Python 3.7.3 (default, Nov 15 2019, 04:04:52)
//        [Clang 11.0.0 (clang-1100.0.33.16)] on darwin
//        Type "help", "copyright", "credits" or "license" for more information.
//        >>> import baseconvert
//        >>> import random
//        >>> s = baseconvert.base(random.getrandbits(128), 10, 32, string=True).lower()
//        >>> s
//        'v0shjrp37vv838ktdf7iajtit'
//        >>> uid = '0v' + '.'.join(s[i:i+5] for i in range(0, len(s), 5))[::-1]
//        >>> uid
//        '0vtitja.i7fdt.k838v.v73pr.jhs0v'
//        >>>
        
        print("Cookie:", HTTPCookieStorage.shared.cookies(for: ursus.url) ?? [])
        
        cancellable = ursus.connect()
            .flatMap { value -> URLSession.DataTaskPublisher in
                self.ursus.connectEventSource()
                return try! self.ursus.poke(
                    ship: "habsun-sansep-filfyr-fotpec--simlun-ticrus-matzod-marzod",
                    app: "chat-store",
                    mark: "json",
                    json: Message(
                        path: "/~/~habsun-sansep-filfyr-fotpec--simlun-ticrus-matzod-marzod/mc",
                        envelope: Envelope(
                            uid: "0vtitja.i7fdt.k838v.v73pr.jhs0v",
                            number: 1,
                            author: "~habsun-sansep-filfyr-fotpec--simlun-ticrus-matzod-marzod",
                            when: Int(Date().timeIntervalSince1970 * 1000),
                            letter: [
                                "text": "hello world!"
                            ]
                        )
                    )
                )
            }
            .sink(
                receiveCompletion: { completion in
                    print("Cookie:", HTTPCookieStorage.shared.cookies(for: self.ursus.url) ?? [])
                    print(completion)
                },
                receiveValue: { value in
                    print("Cookie:", HTTPCookieStorage.shared.cookies(for: self.ursus.url) ?? [])
                    print(String(bytes: value.data, encoding: .utf8)!, value.response)
                }
            )
        
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
