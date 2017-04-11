//
//  StoreRequestStatusType.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/20/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import Foundation

enum StoreRequestStatusType {
    case none
    case inProgress
    case failed(error: NSError)
    case succeeded
}

func ==(lhs: StoreRequestStatusType, rhs: StoreRequestStatusType) -> Bool {
    switch (lhs, rhs) {
    case (.inProgress, .inProgress):
        return true
        
    case (.none, .none):
        return true
        
    case (let .failed(error1), let .failed(error2)):
        return error1.localizedDescription == error2.localizedDescription
        
    case (.succeeded, .succeeded):
        return true
        
    default:
        return false
    }
}
