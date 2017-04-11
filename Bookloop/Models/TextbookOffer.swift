//
//  TextbookOffer.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class TextbookOffer: BLObject {
    var user: User
    var textbook: Textbook
    var condition: TextbookCondition
    var completed: Bool
    var madePublicAt: Date?
    
    var isPublic: Bool {
        return self.madePublicAt != nil
    }
    
    init(parseObject: PFObject) {
        
        self.user = User(parseUser: parseObject["user"] as! PFUser)
        self.textbook = Textbook(parseObject: parseObject["textbook"] as! PFObject)
        self.condition = TextbookCondition(rawValue: parseObject["condition"] as! Int)!
        self.completed = parseObject["completed"] as! Bool
        self.madePublicAt = parseObject["madePuplicAt"] as? Date
        
        super.init()
        
        self.id = parseObject.objectId!
        self.createdAt = parseObject.createdAt!
        self.parseClassName = "TextbookOffer"
    }
    
    init(user: User, textbook: Textbook, condition: TextbookCondition) {
        self.user = user
        self.textbook = textbook
        self.condition = condition
        self.completed = false
        
        super.init()
        
        self.createdAt = Date()
        self.parseClassName = "TextbookOffer"
    }
    
    func parseObject() -> PFObject {
        let object = PFObject(className: "TextbookOffer")
        
        let userObject = PFUser(withoutDataWithObjectId: user.id)
        object["user"] = userObject
        let textbookObject = PFObject(withoutDataWithClassName: "Textbook", objectId: textbook.id)
        object["textbook"] = textbookObject
        object["condition"] = condition.rawValue
        object["completed"] = completed
        
        return object
    }
    
    
}

extension Sequence where Iterator.Element == TextbookOffer {
    func filterNotPublic () -> [TextbookOffer] {
        return self.filter { !($0.isPublic) }
    }
}
