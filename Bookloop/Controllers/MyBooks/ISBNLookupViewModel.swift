//
//  ISBNLookupViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/18/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class ISBNLookupViewModel: NSObject {
    
    let ISBN = MutableProperty("")
    let ISBNIsValid = MutableProperty(false)
    let textbookResult: MutableProperty<Textbook?> = MutableProperty(nil)
    
    let alertMessageSignal: Signal<AlertType, NoError>
    
    fileprivate let store = RemoteStore()
    fileprivate let alertMessageObserver: Observer<AlertType, NoError>
    fileprivate let requesting: Bool
    
    lazy var textbookLookupAction: Action<UIButton, Textbook?, NSError>! = { [unowned self] _ in
        return Action(enabledIf: self.ISBNIsValid, { _ in
            self.alertMessageObserver.sendNext(.default)
            return self.store.textbookWithISBN(self.ISBN.value)
        })
    }()
    
    init(requesting: Bool) {
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AlertType, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        self.requesting = requesting
        
        self.ISBNIsValid <~ ISBN.producer.map { isbn in
            isbn.characters.count == 10 || isbn.characters.count == 13
        }
        
        super.init()
        
        textbookResult <~ self.textbookLookupAction.values
        
        // Alerts
        self.textbookLookupAction.events
            .map { [unowned self] event in self.messageAlertMapping(event) }
            .observe(alertMessageObserver)
    }
    
    func messageAlertMapping(_ event: Event<Textbook?, NSError>) -> AlertType {
        switch event {
        case let .failed(error):
            return (.error(message: error.localizedDescription))
        case let .next(textbook):
            if textbook != nil {
                return (.dismiss)
            } else {
                return (.error(message: "Couldn't find textbook matching ISBN"))
            }
        default:
            return (.ignore)
        }
    }
    
    func textbookResultViewModel() -> TextbookResultViewModel {
        return TextbookResultViewModel(textbook: self.textbookResult.value!, requesting: self.requesting)
    }
}
