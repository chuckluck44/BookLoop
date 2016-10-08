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
    private let requesting: Bool
    private let textbook: Textbook
    
    // Output
    var condition: Int
    
    
    private let store = RemoteStore()
    
    // Alerts
    let alertMessageSignal: Signal<AlertType, NoError>
    private let alertMessageObserver: Observer<AlertType, NoError>
    
    // Actions
    lazy var addTextbookAction: Action<UIBarButtonItem, Void, NSError> = { [unowned self] _ in
        if self.requesting { return self.requestTextbookAction }
        else { return self.offerTextbookAction }
    }()
    
    private lazy var requestTextbookAction: Action<UIBarButtonItem, Void, NSError>! = { [unowned self] _ in
        return Action { _ in
            self.alertMessageObserver.sendNext(.Default)
            return self.store.createTextbookRequest(self.textbook, condition: self.condition)
        }
    }()
    
    private lazy var offerTextbookAction: Action<UIBarButtonItem, Void, NSError>! = { [unowned self] _ in
        return Action { _ in
            self.alertMessageObserver.sendNext(.Default)
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
    
    func messageAlertMapping(event: Event<Void, NSError>) -> AlertType {
        switch event {
        case let .Failed(error):
            return .Error(message: error.localizedDescription)
        case .Completed:
            return .Success(message: "Successfully added book")
        default:
            return .Ignore
        }
    }
}
