//
//  StoreRequestStatusType.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/20/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import Foundation

enum StoreRequestStatusType {
    case None
    case InProgress
    case Failed(error: NSError)
    case Succeeded
}

func ==(lhs: StoreRequestStatusType, rhs: StoreRequestStatusType) -> Bool {
    switch (lhs, rhs) {
    case (.InProgress, .InProgress):
        return true
        
    case (.None, .None):
        return true
        
    case (let .Failed(error1), let .Failed(error2)):
        return error1.localizedDescription == error2.localizedDescription
        
    case (.Succeeded, .Succeeded):
        return true
        
    default:
        return false
    }
}