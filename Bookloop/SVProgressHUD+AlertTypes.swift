//
//  SVProgressHUD+AlertTypes.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/30/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import Foundation
import SVProgressHUD

enum AlertType {
    case Default
    case Status(message: String)
    case Error(message: String)
    case Success(message: String)
    case Info(message: String)
    case Dismiss
    case Ignore
}
 
extension SVProgressHUD {
    class func show(type: AlertType) {
        switch type {
        case .Default:
            SVProgressHUD.show()
        case let .Status(message):
            SVProgressHUD.showWithStatus(message)
        case let .Error(message):
            SVProgressHUD.showErrorWithStatus(message)
        case let .Success(message):
            SVProgressHUD.showSuccessWithStatus(message)
        case let .Info(message):
            SVProgressHUD.showInfoWithStatus(message)
        case .Dismiss:
            SVProgressHUD.dismiss()
        case .Ignore:
            return
        }
    }
    
    class func showStoreRequestStatus(status: StoreRequestStatusType) {
        switch status {
        case .InProgress:
            SVProgressHUD.show()
        case let .Failed(error: error):
            SVProgressHUD.showErrorWithStatus(error.localizedDescription)
        case .Succeeded:
            SVProgressHUD.dismiss()
        case .None:
            return
        }
    }
}