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
    
    private let store = RemoteStore()
    private let alertMessageObserver: Observer<AlertType, NoError>
    private let requesting: Bool
    
    lazy var textbookLookupAction: Action<UIButton, Textbook?, NSError>! = { [unowned self] _ in
        return Action(enabledIf: self.ISBNIsValid, { _ in
            self.alertMessageObserver.sendNext(.Default)
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
    
    func messageAlertMapping(event: Event<Textbook?, NSError>) -> AlertType {
        switch event {
        case let .Failed(error):
            return (.Error(message: error.localizedDescription))
        case let .Next(textbook):
            if textbook != nil {
                return (.Dismiss)
            } else {
                return (.Error(message: "Couldn't find textbook matching ISBN"))
            }
        default:
            return (.Ignore)
        }
    }
    
    func textbookResultViewModel() -> TextbookResultViewModel {
        return TextbookResultViewModel(textbook: self.textbookResult.value!, requesting: self.requesting)
    }
}
