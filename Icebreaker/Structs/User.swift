//
//  User.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit

struct User{

    //defining our properties for our model layer
    var email: String?
    var name: String?
    var imageUrl1: String?
    var major: String?
    var year: String?
    var uid: String?
    var username: String?
    
    
    init(dictionary: [String: Any]) {
        //initialize user here
        self.email = dictionary["email"] as? String
        self.name = dictionary["username"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.major = dictionary["major"] as? String ?? ""
        self.year = dictionary["year"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
    }

}
