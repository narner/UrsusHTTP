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
    
    let ursus = Ursus(url: URL(string: "http://192.168.1.65")!, code: "lidlyx-dinmeg-masper-hilbex")

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
        
//        export function uuid() {
//          let str = "0v"
//          str += Math.ceil(Math.random()*8)+"."
//          for (var i = 0; i < 5; i++) {
//            let _str = Math.ceil(Math.random()*10000000).toString(32);
//            _str = ("00000"+_str).substr(-5,5);
//            str += _str+".";
//          }
//
//          return str.slice(0,-1);
//        }
        
        ursus.authenticationRequest().log(.verbose).response { response in
            self.ursus.pokeRequest(
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
                ),
                handler: { event in
                    switch event {
                    case .success:
                        print("Poke handler success")
                    case .failure(let error):
                        print("Poke handler failure:", error)
                    }
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
