//
//  InfoNode.swift
//  Glance
//
//  Created by Anusha on 9/23/17.
//  Copyright © 2017 Anusha. All rights reserved.
//

import Foundation
import UIKit

class InfoNode {
    
    let pinImage = UIImage(named: "BubblePeach")!
    var _textImage = UIImage(named: "compass")!
    
    var textImage: UIImage {
        get {
            return _textImage
        }
        set {
            _textImage = newValue
        }
    }
}
