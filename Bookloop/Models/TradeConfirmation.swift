//
//  TradeConfirmation.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 12/13/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class TradeConfirmation: BLObject {
    var userId: String
    var tradeGroupId: String
    
    init(parseObject: PFObject) {
        self.userId = (parseObject["user"] as! PFUser).objectId!
        self.tradeGroupId = (parseObject["tradeGroup"] as! PFObject).objectId!
        
        super.init()
        
        self.parseClassName = "TradeConfirmation"
    }
}
