//
//  TradeGroup.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

struct TradeStatusOptions: OptionSet {
    let rawValue: Int
    
    static let currentUserAgreed  = TradeStatusOptions(rawValue: 1 << 0)
    static let otherUserAgreed = TradeStatusOptions(rawValue: 1 << 1)
    static let currentUserConfirmed = TradeStatusOptions(rawValue: 1 << 2)
    static let otherUserConfirmed = TradeStatusOptions(rawValue: 1 << 2)
}

class TradeGroup: BLObject {
    var matches: [TextbookMatch]
    var withUser: User
    var tradeStatus: TradeStatusOptions
    
    var agreedTo: Bool {
        return self.tradeStatus.contains(.currentUserAgreed)
    }
    
    init(parseObject: PFObject, currentUser: User, matchObjects: [PFObject], agreementObjects: [PFObject]?, confirmationObjects: [PFObject]?) {
        
        self.matches = []
        
        let users = parseObject["users"] as! [PFUser]
        let otherUser = users.filter { user in user.objectId != currentUser.id}[0]
        
        self.withUser = User(parseUser: otherUser)
        self.matches = matchObjects.map { TextbookMatch(parseObject: $0) }
        self.tradeStatus = []
        
        super.init()
        
        self.id = parseObject.objectId!
        self.createdAt = parseObject.createdAt!
        self.parseClassName = "TradeGroup"
        
        self.setTradeStatusOptions(withAgreementObjects: agreementObjects, andConfirmationObjects: confirmationObjects)
    }
    
    func setTradeStatusOptions(withAgreementObjects agreements: [PFObject]?, andConfirmationObjects confirmations: [PFObject]?) {
        if agreements == nil { return }
        for agreement in agreements! {
            if (agreement["user"] as! PFObject).objectId != withUser.id { self.tradeStatus.update(with: .currentUserAgreed) }
            else { self.tradeStatus.update(with: .otherUserAgreed) }
        }
        
        if confirmations == nil { return }
        for confirmation in confirmations! {
            if (confirmation["user"] as! PFObject).objectId != withUser.id { self.tradeStatus.update(with: .currentUserConfirmed) }
            else { self.tradeStatus.update(with: .otherUserConfirmed) }
        }
    }
    
    func matchedOffersByUser(_ user: User) -> [TextbookOffer] {
        return matches
            .filter { match in match.offer.user.id == user.id }
            .map { match in match.offer}
    }
    
    func matchedRequestsByUser(_ user: User) -> [TextbookRequest] {
        return matches
            .filter { match in match.request.user.id == user.id }
            .map { match in match.request}
    }
    
    func pointCostForUser(_ user: User) -> Int {
        return matches.reduce(0) { total, match in total + match.pointCostForUser(user) }
    }
    
    func priceStringForUser(_ user: User) -> String {
        let price = pointCostForUser(user)
        let dollars = price/100
        let cents = abs(price%100)
        return "\(dollars).\(cents)"
    }
}
