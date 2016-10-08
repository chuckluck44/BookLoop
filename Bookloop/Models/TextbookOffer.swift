//
//  TextbookOffer.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class TextbookOffer: NSObject {
    var id: String?
    var createdAt: NSDate
    var user: User
    var textbook: Textbook
    var condition: Int
    var completed: Bool
    
    init(parseObject: PFObject) {
        self.id = parseObject.objectId
        self.createdAt = parseObject.createdAt!
        self.user = User(parseUser: parseObject["user"] as! PFUser)
        self.textbook = Textbook(parseObject: parseObject["textbook"] as! PFObject)
        self.condition = parseObject["condition"] as! Int
        self.completed = parseObject["completed"] as! Bool
    }
    
    init(user: User, textbook: Textbook, condition: Int) {
        self.createdAt = NSDate()
        self.user = user
        self.textbook = textbook
        self.condition = condition
        self.completed = false
    }
    
    func parseObject() -> PFObject {
        let object = PFObject(className: "TextbookOffer")
        
        let userObject = PFUser(withoutDataWithObjectId: user.id)
        object["user"] = userObject
        let textbookObject = PFObject(withoutDataWithClassName: "Textbook", objectId: textbook.id)
        object["textbook"] = textbookObject
        object["condition"] = condition
        object["completed"] = completed
        
        return object
    }
}
