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
    var name: String
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var work: String?
    var uid: String?
    var phone: String?
    var school: String?
    var gender: String?
    var age: String?
    var city: String?
    var blockedUsers: Array<String>?
    
    
    init(dictionary: [String: Any]) {
        //initialize user here
        self.email = dictionary["email"] as? String
        self.name = dictionary["name"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String 
        self.gender = dictionary["gender"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.work = dictionary["work"] as? String ?? ""
        self.school = dictionary["school"] as? String ?? ""
        self.age = dictionary["age"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.blockedUsers = (dictionary["blockedUsers"] as? Array<String>)
    }

}
