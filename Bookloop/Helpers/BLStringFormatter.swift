//
//  BLStringFormatter.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 12/13/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit

class BLStringFormatter: NSObject {
    
    class func conditionString(for condition: TextbookCondition) -> String {
        switch condition {
        case .likeNew:
            return "Like new"
        case .great:
            return "Great"
        case .good:
            return "Good"
        case .poor:
            return "Poor"
        }
    }
    
    class func conditionDetailString(for condition: TextbookCondition) -> String {
        switch condition {
        case .likeNew:
            return "Barley used"
        case .great:
            return "Used but still in great condition"
        case .good:
            return "Not in perfect condition but still usable, contains notes"
        case .poor:
            return "Fair amount of damage"
        }
    }
}
