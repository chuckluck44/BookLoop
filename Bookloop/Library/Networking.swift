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
import enum Result.NoError

class Networking: NSObject {
    
    class func fetchImageForURL(imageURL: String, observer: Observer<UIImage?, NSError>) {
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(NSURL(string: imageURL)!) { data, response, error in
            if data == nil || error != nil {
                observer.sendFailed(error!)
                return
            }
            observer.sendNext(UIImage(data: data!))
            observer.sendCompleted()
        }
        
        task.resume()
    }
    
    class func requestSignUpWithEmailAndPassword(email: String, password: String, observer: Observer<Bool, NSError>) {
        let user = PFUser()
        user.username = email
        user.password = password
        user.email = email
        
        user.signUpInBackgroundWithBlock { succeeded, error in
            if error != nil {
                observer.sendFailed(error!)
                return
            }
            observer.sendNext(true)
            observer.sendCompleted()
        }
    }
    
    class func requestLoginWithEmailAndPassword(email: String, password: String, observer: Observer<Bool , NSError>) {
        PFUser.logInWithUsernameInBackground(email, password: password) { (user, error) in
            if error != nil {
                observer.sendFailed(error!)
                return
            }
            observer.sendNext(true)
            observer.sendCompleted()
        }
    }
    
    class func fetchTextbookWithISBN(isbn: String, observer: Observer<Textbook?, NSError>) {
        let query = PFQuery(className: "Textbook")
        if isbn.characters.count == 10 {
            query.whereKey("ISBN", equalTo: isbn)
        } else {
            query.whereKey("EAN", equalTo: isbn)
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if error != nil {
                observer.sendFailed(error!)
                return
            }
            
            if objects?.count > 0 {
                let textbook = Textbook(parseObject: objects![0])
                observer.sendNext(textbook)
                observer.sendCompleted()
                return
            }
            
            PFCloud.callFunctionInBackground("textbookMatchingISBN", withParameters: ["isbn":isbn]) { (response, error) in
                if error != nil {
                    observer.sendFailed(error!)
                    return
                }
                
                if response != nil {
                    let textbook = Textbook(parseObject: response! as! PFObject)
                    observer.sendNext(textbook)
                } else {
                    observer.sendNext(nil)
                }
                
                observer.sendCompleted()
            }
        }
    }
    
    class func fetchTradesForCurrentUser(observer: Observer<TradeGroup, NSError>) {
        let query = PFQuery(className: "TradeGroup")
        query.whereKey("users", equalTo: PFUser.currentUser()!)
        query.includeKey("users")
        
        query.findObjectsInBackgroundWithBlock { (trades, error) in
            if error != nil {
                observer.sendFailed(error!)
                return
            }
            for parseObject in trades! {
                let trade = TradeGroup(parseObject: parseObject)
                
                // Get other user
                let users = parseObject["users"] as! [PFUser]
                let otherUser = users.filter { user in user.objectId != PFUser.currentUser()?.objectId }[0]
                
                trade.withUser = User(parseUser: otherUser)
                
                observer.sendNext(trade)
            }
            observer.sendCompleted()
        }
    }
    
    class func fetchTextbookMatchesInTrade(trade: TradeGroup, observer: Observer<TradeGroup, NSError>) {
        let query = PFQuery(className: "TextbookMatch")
        let parseTrade = PFObject(withoutDataWithClassName: "TradeGroup", objectId: trade.id)
        query.whereKey("tradeGroup", equalTo: parseTrade)
        
        query.includeKeys(["offer", "offer.user", "offer.textbook", "request", "request.user", "request.textbook"])
        
        query.findObjectsInBackgroundWithBlock { (matches, error) in
            if error != nil {
                observer.sendFailed(error!)
                return
            }
            
            trade.matches = matches!.map { TextbookMatch(parseObject: $0) }
            observer.sendNext(trade)
            observer.sendCompleted()
        }
    }
    
    class func agreeToTrade(trade: TradeGroup, observer: Observer<(), NSError>) {
        let trade = PFObject(withoutDataWithClassName: "TradeGroup", objectId: trade.id)
        let tradeAgreement = PFObject(className: "TradeAgreement", dictionary: ["user": PFUser.currentUser()!, "tradeGroup": trade])
        tradeAgreement.saveInBackgroundWithBlock { (succeeded, error) in
            if error != nil {
                observer.sendFailed(error!)
                return
            }
            
            observer.sendCompleted()
        }
        
    }
    
    class func confirmTrade(trade: TradeGroup, observer: Observer<(), NSError>) {
        let trade = PFObject(withoutDataWithClassName: "TradeGroup", objectId: trade.id)
        let tradeConfirmation = PFObject(className: "TradeConfirmation", dictionary: ["user": PFUser.currentUser()!, "tradeGroup": trade])
        tradeConfirmation.saveInBackgroundWithBlock { (succeeded, error) in
            if error != nil {
                observer.sendFailed(error!)
                return
            }
            
            observer.sendCompleted()
        }
        
    }
    
    class func fetchTextbookRequestsForUser(user: User, observer: Observer<TextbookRequest, NSError>) {
        let query = PFQuery(className: "TextbookRequest")
        let parseUser =  PFUser(withoutDataWithObjectId: user.id)
        
        query.whereKey("user", equalTo: parseUser)
        query.includeKeys(["textbook", "user"])
        
        query.findObjectsInBackgroundWithBlock { results, error in
            if error != nil {
                observer.sendFailed(error!)
            }
            
            for object in results! {
                let request = TextbookRequest(parseObject: object)
                observer.sendNext(request)
            }
            observer.sendCompleted()
        }
    }
    
    class func fetchTextbookOffersForUser(user: User, observer: Observer<TextbookOffer, NSError>) {
        let query = PFQuery(className: "TextbookOffer")
        let parseUser =  PFUser(withoutDataWithObjectId: user.id)
        
        query.whereKey("user", equalTo: parseUser)
        query.includeKeys(["textbook", "user"])
        
        query.findObjectsInBackgroundWithBlock { results, error in
            if error != nil {
                observer.sendFailed(error!)
            }
            
            for object in results! {
                let offer = TextbookOffer(parseObject: object)
                observer.sendNext(offer)
            }
            observer.sendCompleted()
        }
    }
    
    class func postTextbookRequest(request: TextbookRequest, observer: Observer<Void, NSError>) {
        let requestObject = request.parseObject()
        
        requestObject.saveInBackgroundWithBlock { (succeeded, error) in
            if error != nil {
                observer.sendFailed(error!)
            }
            
            observer.sendCompleted()
        }
    }
    
    class func deleteTextbookRequest(request: TextbookRequest, observer: Observer<Void, NoError>) {
        let requestObject = PFObject(withoutDataWithClassName: "TextbookRequest", objectId: request.id)
        requestObject.deleteEventually()
        observer.sendCompleted()
    }
    
    class func postTextbookOffer(offer: TextbookOffer, observer: Observer<(), NSError>) {
        let offerObject = offer.parseObject()
        
        offerObject.saveInBackgroundWithBlock { (succeeded, error) in
            if error != nil {
                observer.sendFailed(error!)
            }
            
            observer.sendCompleted()
        }
    }
    
    class func deleteTextbookOffer(offer: TextbookOffer, observer: Observer<Void, NoError>) {
        let offerObject = PFObject(withoutDataWithClassName: "TextbookOffer", objectId: offer.id)
        offerObject.deleteEventually()
        observer.sendCompleted()
    }
}
