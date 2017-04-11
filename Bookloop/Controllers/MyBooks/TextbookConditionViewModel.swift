//
//  TextbookConditionViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/19/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class TextbookConditionViewModel: NSObject {

    // Input
    fileprivate let requesting: Bool
    fileprivate let textbook: Textbook
    
    // Output
    var condition: Int
    
    
    fileprivate let store = RemoteStore()
    
    // Alerts
    let alertMessageSignal: Signal<AlertType, NoError>
    fileprivate let alertMessageObserver: Observer<AlertType, NoError>
    
    // Actions
    lazy var addTextbookAction: Action<UIBarButtonItem, Void, NSError> = { [unowned self] _ in
        if self.requesting { return self.requestTextbookAction }
        else { return self.offerTextbookAction }
    }()
    
    fileprivate lazy var requestTextbookAction: Action<UIBarButtonItem, Void, NSError>! = { [unowned self] _ in
        return Action { _ in
            self.alertMessageObserver.sendNext(.default)
            return self.store.createTextbookRequest(self.textbook, condition: self.condition)
        }
    }()
    
    fileprivate lazy var offerTextbookAction: Action<UIBarButtonItem, Void, NSError>! = { [unowned self] _ in
        return Action { _ in
            self.alertMessageObserver.sendNext(.default)
            return self.store.createTextbookOffer(self.textbook, condition: self.condition)
        }
    }()
    
    init(textbook: Textbook, requesting: Bool) {
        self.textbook = textbook
        self.requesting = requesting
        self.condition = 0
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AlertType, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        super.init()
        
        self.addTextbookAction.events
            .map { [unowned self] event in self.messageAlertMapping(event) }
            .observe(alertMessageObserver)
    }
    
    func messageAlertMapping(_ event: Event<Void, NSError>) -> AlertType {
        switch event {
        case let .failed(error):
            return .error(message: error.localizedDescription)
        case .completed:
            return .success(message: "Successfully added book")
        default:
            return .ignore
        }
    }
}
