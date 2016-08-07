//
//  ViewController.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Ursus.GETAuth().then { auth -> Promise<Auth> in
            return Ursus.PUTAuth(oryx: auth.oryx!, ship: "hidret-matped", code: "xxx")
        }.then { auth -> Promise<Auth> in
            return Ursus.DELETEAuth(oryx: auth.oryx!, ship: "hidret-matped")
        }.then { auth in
            print(auth)
        }.error { error in
            print(error)
        }
        
    }

}
