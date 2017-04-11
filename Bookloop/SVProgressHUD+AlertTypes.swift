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
    case `default`
    case status(message: String)
    case error(message: String)
    case success(message: String)
    case info(message: String)
    case dismiss
    case ignore
}
 
extension SVProgressHUD {
    class func show(_ type: AlertType) {
        switch type {
        case .default:
            SVProgressHUD.show()
        case let .status(message):
            SVProgressHUD.show(withStatus: message)
        case let .error(message):
            SVProgressHUD.showError(withStatus: message)
        case let .success(message):
            SVProgressHUD.showSuccess(withStatus: message)
        case let .info(message):
            SVProgressHUD.showInfo(withStatus: message)
        case .dismiss:
            SVProgressHUD.dismiss()
        case .ignore:
            return
        }
    }
    
    class func showStoreRequestStatus(_ status: StoreRequestStatusType) {
        switch status {
        case .inProgress:
            SVProgressHUD.show()
        case let .failed(error: error):
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        case .succeeded:
            SVProgressHUD.dismiss()
        case .none:
            return
        }
    }
}
