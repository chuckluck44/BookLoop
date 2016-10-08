//
//  User.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/27/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class User: NSObject    {
    var id: String
    var createdAt: NSDate
    var firstName: String
    var lastName: String
    var email: String
    var emailVerified: Bool?
    var balance: String
    
    init(parseUser: PFUser) {
        self.id = parseUser.objectId!
        self.createdAt = parseUser.createdAt!
        self.firstName = parseUser["firstName"] as! String
        self.lastName = parseUser["lastName"] as! String
        self.email = parseUser["email"] as! String
        self.emailVerified = parseUser["emailVerified"] as? Bool
        self.balance = "0.00"
        
    }
}
