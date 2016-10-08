//
//  TradeGroup.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class TradeGroup: NSObject {
    var id: String
    var createdAt: NSDate
    var matches: [TextbookMatch]
    var withUser: User?
    
    init(parseObject: PFObject) {
        self.id = parseObject.objectId!
        self.createdAt = parseObject.createdAt!
        self.matches = []
    }
    
    func matchedOffersByUser(user: User) -> [TextbookOffer] {
        return matches
            .filter { match in match.offer.user.id == user.id }
            .map { match in match.offer}
    }
    
    func matchedRequestsByUser(user: User) -> [TextbookRequest] {
        return matches
            .filter { match in match.request.user.id == user.id }
            .map { match in match.request}
    }
    
    func pointCostForUser(user: User) -> Int {
        return matches.reduce(0) { total, match in total + match.pointCostForUser(user) }
    }
    
    func priceStringForUser(user: User) -> String {
        let price = pointCostForUser(user)
        let dollars = price/100
        let cents = abs(price%100)
        return "\(dollars).\(cents)"
    }
}
