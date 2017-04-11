//
//  Networking.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/27/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse
import ReactiveCocoa
import ReactiveSwift
import enum Result.NoError

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Networking: NSObject {
    
    class func fetchImageForURL(_ imageURL: String, observer: Observer<UIImage?, NSError>) {
        let session = URLSession.shared
        
        let task = session.dataTask(with: URL(string: imageURL)!, completionHandler: { data, response, error in
            if data == nil || error != nil {
                observer.send(error: error! as NSError)
                return
            }
            observer.send(value: UIImage(data: data!))
            observer.sendCompleted()
        }) 
        
        task.resume()
    }
    
    class func requestSignUpWithEmailAndPassword(_ email: String, password: String, observer: Observer<Bool, NSError>) {
        let user = PFUser()
        user.username = email
        user.password = password
        user.email = email
        
        user.signUpInBackground { succeeded, error in
            if error != nil {
                observer.send(error: error! as NSError)
                return
            }
            observer.send(value: true)
            observer.sendCompleted()
        }
    }
    
    class func requestLoginWithEmailAndPassword(_ email: String, password: String, observer: Observer<Bool , NSError>) {
        PFUser.logInWithUsername(inBackground: email, password: password) { (user, error) in
            if error != nil {
                observer.send(error: error! as NSError)
                return
            }
            observer.send(value: true)
            observer.sendCompleted()
        }
    }
    
    class func fetchTextbookWithISBN(_ isbn: String, observer: Observer<Textbook?, NSError>) {
        let query = PFQuery(className: "Textbook")
        if isbn.characters.count == 10 {
            query.whereKey("ISBN", equalTo: isbn)
        } else {
            query.whereKey("EAN", equalTo: isbn)
        }
        
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                observer.send(error: error! as NSError)
                return
            }
            
            if objects?.count > 0 {
                let textbook = Textbook(parseObject: objects![0])
                observer.send(value: textbook)
                observer.sendCompleted()
                return
            }
            
            PFCloud.callFunction(inBackground: "textbookMatchingISBN", withParameters: ["isbn":isbn]) { (response, error) in
                if error != nil {
                    observer.send(error: error! as NSError)
                    return
                }
                
                if response != nil {
                    let textbook = Textbook(parseObject: response! as! PFObject)
                    observer.send(value: textbook)
                } else {
                    observer.send(value: nil)
                }
                
                observer.sendCompleted()
            }
        }
    }
    
    class func fetchTradesForCurrentUser(_ observer: Observer<TradeGroup, NSError>) {
        let query = PFQuery(className: "TradeGroup")
        query.whereKey("users", equalTo: PFUser.current()!)
        query.includeKey("users")
        
        query.findObjectsInBackground { (trades, error) in
            if error != nil {
                observer.send(error: error! as NSError)
                return
            }
            /*
            for parseObject in trades! {
                let trade = TradeGroup(parseObject: parseObject, currentUser: c)
                
                // Get other user
                let users = parseObject["users"] as! [PFUser]
                let otherUser = users.filter { user in user.objectId != PFUser.currentUser()?.objectId }[0]
                
                trade.withUser = User(parseUser: otherUser)
                
                observer.sendNext(trade)
            }
            observer.sendCompleted()
 */
        }
    }
    
    class func fetchTextbookMatchesInTrade(_ trade: TradeGroup, observer: Observer<TradeGroup, NSError>) {
        let query = PFQuery(className: "TextbookMatch")
        let parseTrade = PFObject(withoutDataWithClassName: "TradeGroup", objectId: trade.id)
        query.whereKey("tradeGroup", equalTo: parseTrade)
        
        query.includeKeys(["offer", "offer.user", "offer.textbook", "request", "request.user", "request.textbook"])
        
        query.findObjectsInBackground { (matches, error) in
            if error != nil {
                observer.send(error: error! as NSError)
                return
            }
            
            trade.matches = matches!.map { TextbookMatch(parseObject: $0) }
            observer.send(value: trade)
            observer.sendCompleted()
        }
    }
    
    class func agreeToTrade(_ trade: TradeGroup, observer: Observer<(), NSError>) {
        let trade = PFObject(withoutDataWithClassName: "TradeGroup", objectId: trade.id)
        let tradeAgreement = PFObject(className: "TradeAgreement", dictionary: ["user": PFUser.current()!, "tradeGroup": trade])
        tradeAgreement.saveInBackground { (succeeded, error) in
            if error != nil {
                observer.send(error: error! as NSError)
                return
            }
            
            observer.sendCompleted()
        }
        
    }
    
    class func confirmTrade(_ trade: TradeGroup, observer: Observer<(), NSError>) {
        let trade = PFObject(withoutDataWithClassName: "TradeGroup", objectId: trade.id)
        let tradeConfirmation = PFObject(className: "TradeConfirmation", dictionary: ["user": PFUser.current()!, "tradeGroup": trade])
        tradeConfirmation.saveInBackground { (succeeded, error) in
            if error != nil {
                observer.send(error: error! as NSError)
                return
            }
            
            observer.sendCompleted()
        }
        
    }
    
    class func fetchTextbookRequestsForUser(_ user: User, observer: Observer<TextbookRequest, NSError>) {
        let query = PFQuery(className: "TextbookRequest")
        let parseUser =  PFUser(withoutDataWithObjectId: user.id)
        
        query.whereKey("user", equalTo: parseUser)
        query.includeKeys(["textbook", "user"])
        
        query.findObjectsInBackground { results, error in
            if error != nil {
                observer.send(error: error! as NSError)
            }
            
            for object in results! {
                let request = TextbookRequest(parseObject: object)
                observer.send(value: request)
            }
            observer.sendCompleted()
        }
    }
    
    class func fetchTextbookOffersForUser(_ user: User, observer: Observer<TextbookOffer, NSError>) {
        let query = PFQuery(className: "TextbookOffer")
        let parseUser =  PFUser(withoutDataWithObjectId: user.id)
        
        query.whereKey("user", equalTo: parseUser)
        query.includeKeys(["textbook", "user"])
        
        query.findObjectsInBackground { results, error in
            if error != nil {
                observer.send(error: error! as NSError)
            }
            
            for object in results! {
                let offer = TextbookOffer(parseObject: object)
                observer.send(value: offer)
            }
            observer.sendCompleted()
        }
    }
    
    class func postTextbookRequest(_ request: TextbookRequest, observer: Observer<Void, NSError>) {
        let requestObject = request.parseObject()
        
        requestObject.saveInBackground { (succeeded, error) in
            if error != nil {
                observer.send(error: error! as NSError)
            }
            
            observer.sendCompleted()
        }
    }
    
    class func deleteTextbookRequest(_ request: TextbookRequest, observer: Observer<Void, NoError>) {
        let requestObject = PFObject(withoutDataWithClassName: "TextbookRequest", objectId: request.id)
        requestObject.deleteEventually()
        observer.sendCompleted()
    }
    
    class func postTextbookOffer(_ offer: TextbookOffer, observer: Observer<(), NSError>) {
        let offerObject = offer.parseObject()
        
        offerObject.saveInBackground { (succeeded, error) in
            if error != nil {
                observer.send(error: error! as NSError)
            }
            
            observer.sendCompleted()
        }
    }
    
    class func deleteTextbookOffer(_ offer: TextbookOffer, observer: Observer<Void, NoError>) {
        let offerObject = PFObject(withoutDataWithClassName: "TextbookOffer", objectId: offer.id)
        offerObject.deleteEventually()
        observer.sendCompleted()
    }
    
    // Messaging
    
    class func fetchChatsForUser(_ user: User, page: Int, observer: Observer<Chat, NSError>) {
        let query = PFQuery(className: "Chat")
        let parseUser =  PFUser(withoutDataWithObjectId: user.id)
        
        query.whereKey("user", equalTo: parseUser)
        
        query.findObjectsInBackground { results, error in
            if error != nil {
                observer.send(error: error! as NSError)
            }
            
            for object in results! {
                let chat = Chat(parseObject: object, currentUser: user)
                observer.send(value: chat)
            }
            observer.sendCompleted()
        }
    }
    
    
}
