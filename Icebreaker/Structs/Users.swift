//
//  Users.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation

struct Users{
    
    let email: String
    let imageUrl1: String
    let major: String
    let username: String
    let uid: String
    let year: String
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.year = dictionary["year"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.major = dictionary["major"] as? String ?? ""
    }
}
