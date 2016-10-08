//
//  TextbookMatch.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class TextbookMatch: NSObject {
    var offer: TextbookOffer
    var request: TextbookRequest
    
    init(parseObject: PFObject) {
        self.offer = TextbookOffer(parseObject: parseObject["offer"] as! PFObject)
        self.request = TextbookRequest(parseObject: parseObject["request"] as! PFObject)
    }
    
    func pointCostForUser(user: User) -> Int {
        let price = offer.textbook.price
        if offer.user.id == user.id {
            return price
        } else {
            return -price
        }
    }
}
