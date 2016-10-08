//
//  RemoteStore.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/29/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Parse
import enum Result.NoError

class RemoteStore: NSObject {
    
    func currentUser() -> User? {
        guard let user = PFUser.currentUser() else {
            return nil
        }
        return User(parseUser: user)
    }
    
    func imageWithURL(imageURL: String) -> SignalProducer<UIImage?, NSError> {
        return SignalProducer { observer, _ in
            Networking.fetchImageForURL(imageURL, observer: observer)
        }
    }
    
    func signUpWithEmailAndPassword(email: String, password: String) -> SignalProducer<Bool,NSError> {
        return SignalProducer { observer, _ in
            Networking.requestSignUpWithEmailAndPassword(email, password: password, observer: observer)
        }
    }
    
    func loginWithEmailAndPassword(email: String, password: String) -> SignalProducer<Bool, NSError> {
        return SignalProducer { observer, _ in
            Networking.requestLoginWithEmailAndPassword(email, password: password, observer: observer)
        }
    }
    
    func textbookWithISBN(isbn: String) -> SignalProducer<Textbook?, NSError> {
        return SignalProducer { observer, _ in
            Networking.fetchTextbookWithISBN(isbn, observer: observer)
        }
    }
    
    func tradesForCurrentUser() -> SignalProducer<TradeGroup, NSError> {
        return emptyTradesForCurrentUser()
            .flatMap(.Merge) { [unowned self] trade in
                return self.textbookMatchesInTrade(trade)
            }
    }
    
    func emptyTradesForCurrentUser() -> SignalProducer<TradeGroup, NSError> {
        return SignalProducer { observer, _ in
            Networking.fetchTradesForCurrentUser(observer)
        }
    }
    
    func textbookMatchesInTrade(trade: TradeGroup) -> SignalProducer<TradeGroup, NSError> {
        return SignalProducer { observer, _ in
            Networking.fetchTextbookMatchesInTrade(trade, observer: observer)
        }
    }
    
    func textbookRequestsForCurrentUser() -> SignalProducer<TextbookRequest, NSError> {
        return SignalProducer { [unowned self] observer, _ in
            Networking.fetchTextbookRequestsForUser(self.currentUser()!, observer: observer)
        }
    }
    
    func textbookOffersForCurrentUser() -> SignalProducer<TextbookOffer, NSError> {
        return SignalProducer { [unowned self] observer, _ in
            Networking.fetchTextbookOffersForUser(self.currentUser()!, observer: observer)
        }
    }
    
    func createTextbookRequest(textbook: Textbook, condition: Int) -> SignalProducer<(), NSError> {
        let request = TextbookRequest(user: self.currentUser()!, textbook: textbook, condition: condition)
        return SignalProducer { observer, _ in
            Networking.postTextbookRequest(request, observer: observer)
        }
    }
    
    func deleteTextbookRequest(request: TextbookRequest) -> SignalProducer<Void, NoError> {
        return SignalProducer { observer, _ in
            Networking.deleteTextbookRequest(request, observer: observer)
        }
    }
    
    func createTextbookOffer(textbook: Textbook, condition: Int) -> SignalProducer<(), NSError> {
        let offer = TextbookOffer(user: self.currentUser()!, textbook: textbook, condition: condition)
        return SignalProducer { observer, _ in
            Networking.postTextbookOffer(offer, observer: observer)
        }
    }
    
    func deleteTextbookOffer(offer: TextbookOffer) -> SignalProducer<Void, NoError> {
        return SignalProducer { observer, _ in
            Networking.deleteTextbookOffer(offer, observer: observer)
        }
    }
}
