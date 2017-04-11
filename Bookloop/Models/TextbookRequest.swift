//
//  TextbookRequest.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class TextbookRequest: BLObject {
    var user: User
    var textbook: Textbook
    var minimumCondition: TextbookCondition
    var completed: Bool
    var madePublicAt: Date?
    
    var isPublic: Bool {
        return self.madePublicAt != nil
    }
    
    init(parseObject: PFObject) {
        
        self.user = User(parseUser: parseObject["user"] as! PFUser)
        self.textbook = Textbook(parseObject: parseObject["textbook"] as! PFObject)
        self.minimumCondition = TextbookCondition(rawValue: parseObject["condition"] as! Int)!
        self.completed = parseObject["completed"] as! Bool
        self.madePublicAt = parseObject["madePuplicAt"] as? Date
        
        super.init()
        
        self.id = parseObject.objectId!
        self.createdAt = parseObject.createdAt!
        self.parseClassName = "TextbookRequest"
    }
    
    init(user: User, textbook: Textbook, minimumCondition: TextbookCondition) {
        
        self.user = user
        self.textbook = textbook
        self.minimumCondition = minimumCondition
        self.completed = false
        
        super.init()
        
        self.createdAt = Date()
        self.parseClassName = "TextbookRequest"
    }
    
    func parseObject() -> PFObject {
        var object = PFObject(className: "TextbookRequest")
        if self.id != "" {
            object = PFObject(withoutDataWithClassName: "TextbookRequest", objectId: self.id)
        }
        
        let userObject = PFUser(withoutDataWithObjectId: user.id)
        object["user"] = userObject
        let textbookObject = PFObject(withoutDataWithClassName: "Textbook", objectId: textbook.id)
        object["textbook"] = textbookObject
        object["condition"] = minimumCondition.rawValue
        object["completed"] = completed
        object["madePublicAt"] = madePublicAt
        
        return object
    }
    
}

extension Sequence where Iterator.Element == TextbookRequest {
    func filterNotPublic () -> [TextbookRequest] {
        return self.filter { !($0.isPublic) }
    }
}
