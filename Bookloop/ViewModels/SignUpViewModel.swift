//
//  SignUpViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/25/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class SignUpViewModel: NSObject {
    
    typealias AlertMessage = (type: AlertType, message: String?)
    
    // Inputs
    let email = MutableProperty("")
    let password = MutableProperty("")
    
    // Ouputs
    let infoIsValid = MutableProperty(false)
    let isSignedUp = MutableProperty(false)
    let alertMessageSignal: Signal<AlertType, NoError>
    
    // Actions
    lazy var signUpAction: Action<UIButton, Bool, NSError>! = { [unowned self] _ in
        return Action(enabledIf: self.infoIsValid, { _ in
            self.alertMessageObserver.sendNext(.status(message: "Logging in..."))
            return self.store.signUpWithEmailAndPassword(self.email.value, password: self.password.value)
        })
    }()
    
    fileprivate let store = RemoteStore()
    fileprivate let alertMessageObserver: Observer<AlertType, NoError>
    
    override init() {
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AlertType, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        // Valid sign up info
        let validEmailSignal = email.producer.map { text in text.characters.count > 0 }
        let validPasswordSignal = password.producer.map { text in text.characters.count > 0 }
        infoIsValid <~ validEmailSignal.combineLatestWith(validPasswordSignal).map {$0 && $1}.skipRepeats()
        
        super.init()
        
        // Update sign up progress
        self.signUpAction.events
            .map { [unowned self] event in self.messageAlertMapping(event) }
            .observe(alertMessageObserver)
        
        // Sign up successful
        signUpAction.values.observeNext { _ in NotificationCenter.default.post(name: Notification.Name(rawValue: signUpSuccessfulNotification), object: nil) }
        isSignedUp <~ signUpAction.values
    }
    
    func isValidEmail(_ email: String) -> Bool {
        return email.range(of: "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$", options: .regularExpression) != nil
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.characters.count > 5
    }
    
    func messageAlertMapping(_ event: Event<Bool, NSError>) -> AlertType {
        switch event {
        case let .failed(error):
            return .error(message: error.localizedDescription)
        case .completed:
            return .success(message: "Sign up successful!")
        default:
            return .ignore
        }
    }
}
