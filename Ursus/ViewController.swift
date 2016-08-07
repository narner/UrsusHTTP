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
    
    // MARK: Interface outlets
    
    @IBOutlet var shipTextField: UITextField!
    @IBOutlet var codeTextField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    
    // MARK: Interface actions
    
    @IBAction func submitButtonTapped() {
        setTextFieldsEnabled(false)
        authenticate(withShip: shipTextField.text!, andCode: codeTextField.text!)
    }
    
    // MARK: Interface mutation
    
    private func setTextFieldsEnabled(enabled: Bool) {
        shipTextField.enabled = enabled
        codeTextField.enabled = enabled
        shipTextField.backgroundColor = enabled ? UIColor.whiteColor() : UIColor.lightGrayColor()
        codeTextField.backgroundColor = enabled ? UIColor.whiteColor() : UIColor.lightGrayColor()
    }
    
    // MARK: Requests
    
    private func authenticate(withShip ship: String, andCode code: String) {
        Ursus.GETAuth().then { auth -> Promise<Auth> in
            return Ursus.PUTAuth(oryx: auth.oryx!, ship: ship, code: code)
        }.then { auth in
            self.presentSuccessViewController(auth)
        }.error { error in
            self.presentErrorViewController(error as NSError)
        }
    }
    
    // MARK: Alerts
    
    private func presentSuccessViewController(auth: Auth) {
        let viewController = UIAlertController(title: "Success", message: "Logged in as ~\(auth.user!)", preferredStyle: .Alert)
        
        viewController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.setTextFieldsEnabled(true)
        }))
        
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    private func presentErrorViewController(error: NSError) {
        let viewController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        
        viewController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.setTextFieldsEnabled(true)
        }))
            
        presentViewController(viewController, animated: true, completion: nil)
    }

}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case shipTextField:
            codeTextField.becomeFirstResponder()
        case codeTextField:
            setTextFieldsEnabled(false)
            authenticate(withShip: shipTextField.text!, andCode: codeTextField.text!)
        default:
            break
        }
        
        return true
    }
    
}
