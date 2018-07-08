//
//  Person.swift
//  Glance
//
//  Created by Anusha on 9/22/17.
//  Copyright © 2017 Anusha. All rights reserved.
//

import Foundation

class Person {
    
    private var _email = "Email"
    private var _password = "Password"
    var _info = "Information"
    
    var email: String {
        get {
            return _email
        }
        set {
            _email = newValue
        }
    }
    
    var password: String {
        get {
            return _password
        }
        set {
            _password = newValue
        }
    }
    
    var info: String {
        get {
            return _info
        }
        set {
            _info = newValue
        }
    }
}


