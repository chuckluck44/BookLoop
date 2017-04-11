//
//  Message.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 11/1/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import Parse
import JSQMessagesViewController

class Message: BLObject {
    var text: String
    var sender: User
    
    init(parseObject: PFObject) {
        
        self.text = parseObject["text"] as! String
        self.sender = User(parseUser: parseObject["sender"] as! PFUser)
        
        super.init()
        
        self.id = parseObject.objectId!
        self.createdAt = parseObject.createdAt!
        self.parseClassName = "Message"
    }
    
    init(sender: User, text: String) {
        
        self.sender = sender
        self.text = text
        
        super.init()
        
        self.id = ""
        self.createdAt = Date()
        self.parseClassName = "Message"
    }
    
    func parseObject() -> PFObject {
        let userObject = PFUser(withoutDataWithObjectId: sender.id)
        return PFObject(className: "Message",
                        dictionary: ["sender" : userObject, "text" : text])
    }
    
    func jsqMessage() -> JSQMessage {
        return JSQMessage(senderId: sender.id, senderDisplayName: sender.firstName, date: createdAt, text: text)
    }
}
