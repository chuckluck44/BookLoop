//
//  TradeGroupFactory.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 12/21/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

class TradeGroupFactory: NSObject {
    var tradeGroupObjects: [PFObject] = []
    var matchObjects: [PFObject] = []
    var agreementObjects: [PFObject] = []
    var confirmationObjects: [PFObject] = []
    var currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func buildTradeGroups() -> [TradeGroup] {
        
        var tradeGroups: [TradeGroup] = []
        
        let matchMap = self.tradeGroupIdMap(with: matchObjects)
        let agreementMap = self.tradeGroupIdMap(with: agreementObjects)
        let confirmationMap = self.tradeGroupIdMap(with: confirmationObjects)
        
        for tradeGroupObject in tradeGroupObjects {
            let tradeGroup = TradeGroup(parseObject: tradeGroupObject,
                                        currentUser: self.currentUser,
                                        matchObjects: matchMap[tradeGroupObject.objectId!]!,
                                        agreementObjects: agreementMap[tradeGroupObject.objectId!],
                                        confirmationObjects: confirmationMap[tradeGroupObject.objectId!])
            tradeGroups.append(tradeGroup)
        }
        
        return tradeGroups
    }
    
    private func tradeGroupIdMap(with objects: [PFObject]) -> [String: [PFObject]] {
        var map: [String: [PFObject]] = [:]
        for object in objects {
            let tradeGroupId = (object["tradeGroup"] as! PFObject).objectId!
            if var mappedObjects = map[tradeGroupId] {
                mappedObjects.append(object)
            } else {
                map[tradeGroupId] = [object]
            }
        }
        return map
    }
}
