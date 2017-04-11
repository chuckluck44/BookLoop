//
//  BLObject.swift
//  
//
//  Created by Charley Luckhardt on 12/8/16.
//
//

import UIKit
import Parse

class BLObject: NSObject {
    var id: String
    var createdAt: Date
    var parseClassName: String
    
    override init() {
        self.id = ""
        self.createdAt = Date()
        self.parseClassName = ""
    }
    
    func emptyPFObject() -> PFObject {
        return PFObject(withoutDataWithClassName: self.parseClassName, objectId: self.id)
    }
}
