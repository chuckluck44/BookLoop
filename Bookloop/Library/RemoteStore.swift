//
//  RemoteStore.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/29/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveSwift
import Parse
import PromiseKit
import enum Result.NoError

typealias SuccessHandler = (Any?) -> Void
typealias FailureHandler = (Error) -> Void

enum NetworkRequestStatus {
    case none
    case inProgress
    case succeeded
    case failed
}

class RemoteStore: NSObject {
    
    func currentUser() -> User? {
        guard let user = PFUser.current() else {
            return nil
        }
        return User(parseUser: user)
    }
    
    func imageWithURL(_ imageURL: String) -> SignalProducer<UIImage?, NSError> {
        return SignalProducer { observer, _ in
            Networking.fetchImageForURL(imageURL, observer: observer)
        }
    }
    
    func signUp(email: String, password: String) -> Promise<Bool> {
        let user = PFUser()
        user.username = email
        user.password = password
        user.email = email
        
        return wrap(user.signUpInBackground)
    }
 
    func login(email: String, password: String) -> Promise<PFUser> {
        return Promise { fulfill, reject in
            PFUser.logInWithUsername(inBackground: email, password: password) { (user, error) in
                if error != nil { return reject(error!) }
                
                fulfill(user!)
            }
        }
    }
    
    func logOut() -> Promise<Void> {
        return wrap(PFUser.logOutInBackground)
    }
    
    func getTextbook(withISBN isbn: String, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        let query = PFQuery(className: "Textbook")
        if isbn.characters.count == 10 {
            query.whereKey("ISBN", equalTo: isbn)
        } else {
            query.whereKey("EAN", equalTo: isbn)
        }
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                failure(error!)
                return
            }
            
            if (objects?.count)! > 0 {
                let textbook = Textbook(parseObject: objects![0])
                success(textbook)
                return
            }
            
            PFCloud.callFunction(inBackground: "textbookMatchingISBN", withParameters: ["isbn":isbn]) { (response, error) in
                if error != nil {
                    failure(error!)
                    return
                }
                
                if response != nil {
                    let textbook = Textbook(parseObject: response! as! PFObject)
                    success(textbook)
                } else {
                    success(nil)
                }
            }
        }
    }

    func getTradesForCurrentUser() -> Promise<[TradeGroup]> {
        let tradeGroupFactory = TradeGroupFactory(currentUser: self.currentUser()!)
        
        return self.getTradeGroupObjectsForCurrentUser().then { results -> Promise<[PFObject]> in
            tradeGroupFactory.tradeGroupObjects = results
            return self.getTextbookMatches(forTradeGroupObjects: results)
        }.then { results -> Promise<[PFObject]> in
            tradeGroupFactory.matchObjects = results
            return self.getTradeAgreements(forTradeGroupObjects: tradeGroupFactory.tradeGroupObjects)
        }.then { results -> Promise<[PFObject]> in
            tradeGroupFactory.agreementObjects = results
            if results.count == 2 {
                return self.getTradeConfirmations(forTradeGroupObjects: tradeGroupFactory.tradeGroupObjects)
            } else {
                return Promise(value: [])
            }
        }.then { results in
            tradeGroupFactory.confirmationObjects = results
            return Promise(value: tradeGroupFactory.buildTradeGroups())
        }
    }
    
    func getCompletedTradesForCurrentUser(before date: Date) -> Promise<[TradeGroup]> {
        let tradeGroupFactory = TradeGroupFactory(currentUser: self.currentUser()!)
        
        return self.getTradeGroupObjectsForCurrentUser().then { results -> Promise<[PFObject]> in
            tradeGroupFactory.tradeGroupObjects = results
            return self.getTextbookMatches(forTradeGroupObjects: results)
            }.then { results -> Promise<[PFObject]> in
                tradeGroupFactory.matchObjects = results
                return self.getTradeAgreements(forTradeGroupObjects: tradeGroupFactory.tradeGroupObjects)
            }.then { results -> Promise<[PFObject]> in
                tradeGroupFactory.agreementObjects = results
                if results.count == 2 {
                    return self.getTradeConfirmations(forTradeGroupObjects: tradeGroupFactory.tradeGroupObjects)
                } else {
                    return Promise(value: [])
                }
            }.then { results in
                tradeGroupFactory.confirmationObjects = results
                return Promise(value: tradeGroupFactory.buildTradeGroups())
        }
    }
    
    func agreeTo(_ trade: TradeGroup) -> Promise<Bool> {
        let object = PFObject(className: "TradeAgreement", dictionary: ["user" : self.currentUser()!.emptyPFObject(), "tradeGroup" : trade.emptyPFObject()])
        return wrap(object.saveInBackground)
    }
    
    func decline(_ trade: TradeGroup) -> Promise<Bool> {
        let object = trade.emptyPFObject()
        return wrap(object.deleteInBackground)
    }
    
    func confirm(_ trade: TradeGroup) -> Promise<Bool> {
        let object = PFObject(className: "TradeConfirmation", dictionary: ["user" : self.currentUser()!.emptyPFObject(), "tradeGroup" : trade.emptyPFObject()])
        return wrap(object.saveInBackground)
    }
    
    func cancel(_ trade: TradeGroup) -> Promise<Bool> {
        let query = PFQuery(className: "TradeAgreement")
        query.whereKey("tradeGroup", equalTo: trade.emptyPFObject())
        
        return wrap(query.getFirstObjectInBackground).then { agreementObject -> Promise<Bool> in
            return wrap(agreementObject.deleteInBackground)
        }
    }
    
    func getTextbookRequestsForCurrentUser() -> Promise<[TextbookRequest]> {
        let query = PFQuery(className: "TextbookRequest")
        let parseUser =  PFUser(withoutDataWithObjectId: self.currentUser()?.id)
        
        query.whereKey("user", equalTo: parseUser)
        query.includeKeys(["textbook", "user"])
        
        return Promise { fulfill, reject in
            query.findObjectsInBackground() { results, error in
                if error != nil { return reject(error!) }
                
                let requests = results!.map { TextbookRequest(parseObject: $0) }
                fulfill(requests)
            }
        }
    }
 
    func getTextbookOffersForCurrentUser() -> Promise<[TextbookOffer]> {
        let query = PFQuery(className: "TextbookOffer")
        let parseUser =  PFUser(withoutDataWithObjectId: self.currentUser()?.id)
        
        query.whereKey("user", equalTo: parseUser)
        query.includeKeys(["textbook", "user"])
        
        return Promise { fulfill, reject in
            query.findObjectsInBackground() { results, error in
                if error != nil { return reject(error!) }
                
                let offers = results!.map { TextbookOffer(parseObject: $0) }
                fulfill(offers)
            }
        }
    }
 
    func request(_ textbook: Textbook, condition: TextbookCondition) -> Promise<Bool> {
        let object = TextbookRequest(user: self.currentUser()!, textbook: textbook, minimumCondition: condition).parseObject()
        
        return wrap(object.saveInBackground)
    }
    
    func offer(_ textbook: Textbook, condition: TextbookCondition) -> Promise<Bool> {
        let object = TextbookOffer(user: self.currentUser()!, textbook: textbook, condition: condition).parseObject()
        return wrap(object.saveInBackground)
    }
    
    func publicizeRequests(_ textbookRequests: [TextbookRequest], andOffers textbookOffers: [TextbookOffer]) -> Promise<Bool> {
        var requestObjects: [PFObject] = []
        for request in textbookRequests {
            let object = PFObject(withoutDataWithClassName: "TextbookRequest", objectId: request.id)
            object["madePublicAt"] = Date()
            requestObjects.append(object)
        }
        var offerObjects: [PFObject] = []
        for offer in textbookOffers {
            let object = PFObject(withoutDataWithClassName: "TextbookOffer", objectId: offer.id)
            object["madePublicAt"] = Date()
            offerObjects.append(object)
        }
        
        return wrap { PFObject.saveAll(inBackground: requestObjects, block: $0) }.then { _ in
            return wrap { PFObject.saveAll(inBackground: offerObjects, block: $0) }
        }
    }
    
    func findMatchesForCurrentUser() -> Promise<Any?> {
        return wrap { PFCloud.callFunction(inBackground: "findMatchesForCurrentUser", withParameters: nil, block: $0) }
    }
 
    /*
    func deleteTextbookOffer(_ offer: TextbookOffer) -> SignalProducer<Void, NoError> {
        return SignalProducer { observer, _ in
            Networking.deleteTextbookOffer(offer, observer: observer)
        }
    }
    */
    
    func delete(_ object: BLObject) -> Promise<Bool> {
        let parseObject = object.emptyPFObject()
        return wrap(parseObject.deleteInBackground)
    }
    
    // Messaging
    
    func fetchChatsForCurrentUser(_ page: Int, completion: @escaping (_ result: [Chat]?, _ error: NSError?) -> Void) {
        let query = PFQuery(className: "Chat")
        let parseUser =  PFUser(withoutDataWithObjectId: currentUser()!.id)
        
        query.whereKey("user", equalTo: parseUser)
        query.order(byDescending: "createdAt")
        query.skip = page * 20
        query.limit = 20
        
        query.findObjectsInBackground { results, error in
            if error != nil {
                completion(nil, error as NSError?)
            }
            
            let chats = results!.map { [unowned self] in Chat(parseObject: $0, currentUser: self.currentUser()!) }
            
            completion(chats, nil)
        }
    }
    
    func fetchMessagesInChat(_ chat: Chat, afterDate: Date, completion: @escaping (_ result: [Message]?, _ error: NSError?) -> Void) {
        let query = PFQuery(className: "Message")
        let chatObject = PFObject(withoutDataWithClassName: "Chat", objectId: chat.id)
        
        query.whereKey("chat", equalTo: chatObject)
        query.whereKey("createdAt", greaterThan: afterDate)
        query.order(byDescending: "createdAt")
        query.limit = 20
        
        query.findObjectsInBackground { results, error in
            if error != nil {
                completion(nil, error as NSError?)
            }
            
            let messages = results!.map { Message(parseObject: $0) }
            
            completion(messages, nil)
        }
    }
    
    func fetchMessagesInChat(_ chat: Chat, beforeDate: Date, completion: @escaping (_ result: [Message]?, _ error: NSError?) -> Void) {
        let query = PFQuery(className: "Message")
        let chatObject = PFObject(withoutDataWithClassName: "Chat", objectId: chat.id)
        
        query.whereKey("chat", equalTo: chatObject)
        query.whereKey("createdAt", lessThan: beforeDate)
        query.order(byDescending: "createdAt")
        query.limit = 20
        
        query.findObjectsInBackground { results, error in
            if error != nil {
                completion(nil, error as NSError?)
            }
            
            let messages = results!.map { Message(parseObject: $0) }
            
            completion(messages, nil)
        }
    }
    
    func sendMessageWithText(_ text: String, completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let message = Message(sender: currentUser()!, text: text)
        let messageObject = message.parseObject()
        
        /*
        messageObject.saveInBackground { (success, error) in
            completion(success, error)
        }
        */
    }
 
    private func getTradeGroupObjectsForCurrentUser() -> Promise<[PFObject]> {
        return Promise { fulfill, reject in
            let query = PFQuery(className: "TradeGroup")
            query.whereKey("users", equalTo: PFUser.current()!)
            query.includeKey("users")
            
            query.findObjectsInBackground { (results, error) in
                if error != nil { return reject(error!) }
                
                fulfill(results!)
            }
        }
    }
    
    private func getCompletedTradeGroupObjectsForCurrentUser() -> Promise<[PFObject]> {
        return Promise { fulfill, reject in
            let query = PFQuery(className: "TradeConfirmation")
            query.whereKey("users", equalTo: PFUser.current()!)
            query.includeKey("tradeGroup")
            
            query.findObjectsInBackground { (results, error) in
                if error != nil { return reject(error!) }
                
                fulfill(results!)
            }
        }
    }
    
    private func getTextbookMatches(forTradeGroupObjects tradeGroupObjects: [PFObject]) -> Promise<[PFObject]> {
        return Promise { fulfill, reject in
            let query = PFQuery(className: "TextbookMatch")
            query.whereKey("tradeGroup", containedIn: tradeGroupObjects)
            query.includeKeys(["request", "request.user", "request.textbook", "offer", "offer.user", "offer.textbook", "tradeGroup"])
            
            query.findObjectsInBackground { (results, error) in
                if error != nil { return reject(error!) }
                
                fulfill(results!)
            }
        }
    }
    
    private func getTradeAgreements(forTradeGroupObjects tradeGroupObjects: [PFObject]) -> Promise<[PFObject]>  {
        return Promise { fulfill, reject in
            let query = PFQuery(className: "TradeAgreement")
            query.whereKey("tradeGroup", containedIn: tradeGroupObjects)
            query.includeKeys(["user", "tradeGroup"])
            
            query.findObjectsInBackground { (results, error) in
                if error != nil { return reject(error!) }
                
                fulfill(results!)
            }
        }
    }
    
    private func getTradeConfirmations(forTradeGroupObjects tradeGroupObjects: [PFObject]) -> Promise<[PFObject]>  {
        return Promise { fulfill, reject in
            let query = PFQuery(className: "TradeAgreement")
            query.whereKey("tradeGroup", containedIn: tradeGroupObjects)
            query.includeKeys(["user", "tradeGroup"])
            
            query.findObjectsInBackground { (results, error) in
                if error != nil { return reject(error!) }
                
                fulfill(results!)
            }
        }
    }
}
