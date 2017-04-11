//
//  Chat.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 11/1/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class Chat: BLObject {
    var user: User
    var lastMessage: Message?
    
    init(parseObject: PFObject, currentUser: User) {
        
        let users = parseObject["users"] as! [PFUser]
        let otherUser = User(parseUser: users.filter { user in user.objectId != currentUser.id }[0])
        self.user = otherUser
        
        let messageObject = parseObject["lastMessage"] as! PFObject?
        if messageObject != nil {
            self.lastMessage = Message(parseObject: messageObject!)
        }
        
        super.init()
        
        self.id = parseObject.objectId!
        self.parseClassName = "Chat"
    }
    
    init(user: User) {
        
        self.user = user
        self.lastMessage = nil
        
        super.init()
        
        self.id = ""
        self.parseClassName = "Chat"
    }
}
