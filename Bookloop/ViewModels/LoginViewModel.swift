//
//  LoginViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/29/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

let signUpSuccessfulNotification = "k_signup_successful"

class LoginViewModel: NSObject {
    
    // Inputs
    let email = MutableProperty("")
    let password = MutableProperty("")
    let waitingForEmailVerification = MutableProperty(false)
    
    // Ouputs
    let infoIsValid = MutableProperty(false)
    let isLoggedIn = MutableProperty(false)
    let alertMessageSignal: Signal<AlertType, NoError>
    
    // Actions
    lazy var loginAction: Action<UIButton, Bool, NSError>! = { [unowned self] _ in
        return Action(enabledIf: self.infoIsValid, { _ in
            self.alertMessageObserver.sendNext(.Status(message: "Logging in..."))
            return self.store.loginWithEmailAndPassword("user@co.edu", password: "password")
        })
    }()
    
    private let store = RemoteStore()
    private let alertMessageObserver: Observer<AlertType, NoError>
    
    override init() {
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AlertType, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
 
        // Valid login info
        let validEmailSignal = email.producer.map { text in text.characters.count > 0 }
        let validPasswordSignal = password.producer.map { text in text.characters.count > 0 }
        infoIsValid <~ validEmailSignal.combineLatestWith(validPasswordSignal).map {$0 && $1}.skipRepeats()
        
        super.init()
        
        // Log in success
        isLoggedIn <~ loginAction.values
        
        let waitingForEmailVerificationSignal  = NSNotificationCenter.defaultCenter()
            .rac_notifications(signUpSuccessfulNotification, object: nil)
            .ignoreError()
        waitingForEmailVerification <~ waitingForEmailVerificationSignal.map { _ in true }
        
        // Alerts
        self.loginAction.events
            .map { [unowned self] event in self.messageAlertMapping(event) }
            .observe(alertMessageObserver)
        
        waitingForEmailVerificationSignal
            .map {_ -> AlertType in .Info(message: "Please validate your email") }
            .start(alertMessageObserver)
    }
    
    func messageAlertMapping(event: Event<Bool, NSError>) -> AlertType {
        switch event {
        case let .Failed(error):
            return .Error(message: error.localizedDescription)
        case .Completed:
            return .Dismiss
        default:
            return .Ignore
        }
    }
}
