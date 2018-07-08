//
//  LogInController.swift
//  Glance
//
//  Created by Anusha on 9/22/17.
//  Copyright © 2017 Anusha. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwiftKeychainWrapper

class LogInController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var infoField: UITextView!
    var person = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoField.layer.borderWidth = 5.0
        self.infoField.layer.borderColor = (UIColor.red as! CGColor)
        self.infoField.layer.cornerRadius = 8;
        
        // Remove keyboard after typing/editing completed by user
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func storeUserData (userID: String) {
        let userdata = ["info": self.infoField.text!] as [String: Any]
        Database.database().reference().child("users").child(userID).setValue(userdata)
    }
    
    
    @IBAction func signIn(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error)
                in
                if error != nil && !(self.infoField.text?.isEmpty)!{
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error)
                        in
                        if user?.uid != nil {
                            self.storeUserData(userID: (user?.uid)!)
                        }
                        KeychainWrapper.standard.set((user?.uid)!, forKey: "uid")
                        self.performSegue(withIdentifier: "loggedIn", sender: nil)
                    }
                }
                else {
                    if let userID = user?.uid {
                        KeychainWrapper.standard.set((userID), forKey: "uid")
                        self.performSegue(withIdentifier: "loggedIn", sender: nil)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
