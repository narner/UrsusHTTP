//
//  ViewController.swift
//  Ursus
//
//  Created by Daniel Clelland on 3/08/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Ursus.GETAuth().then { auth in
            print(auth)
        }.error { error in
            print(error)
        }
    }

}
