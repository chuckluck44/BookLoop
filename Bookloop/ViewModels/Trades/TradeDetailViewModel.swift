//
//  TradeDetailViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class TradeDetailViewModel: NSObject {
    
    let selectedIndex = MutableProperty(0)
    
    let contentChangesSignal: Signal<(), NoError>
    let alertMessageSignal: Signal<AlertType, NoError>
    
    private let trade: TradeGroup
    private let currentUser: User
    private let matchedRequests: [TextbookRequest]
    private let matchedOffers: [TextbookOffer]
    private var cellModels: [TextbookTableViewCellModel]
    
    private let contentChangesObserver: Observer<(), NoError>
    private let alertMessageObserver: Observer<AlertType, NoError>
    
    init(trade: TradeGroup, currentUser: User) {
        self.trade = trade
        self.currentUser = currentUser
        self.matchedRequests = trade.matchedRequestsByUser(currentUser)
        self.matchedOffers = trade.matchedOffersByUser(currentUser)
        self.cellModels = matchedRequests.map { request in TextbookTableViewCellModel(textbook: request.textbook) }
        
        let (contentChangesSignal, contentChangesObserver) = Signal<(), NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AlertType, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        super.init()
        
        self.selectedIndex
            .producer
            .startWithNext { [unowned self] index in
                if index == 0 {
                    self.cellModels = self.matchedRequests.map { request in TextbookTableViewCellModel(textbook: request.textbook) }
                } else {
                    self.cellModels = self.matchedOffers.map { offer in TextbookTableViewCellModel(textbook: offer.textbook) }
                }
                self.contentChangesObserver.sendNext()
            }
        
        
    }
    
    // Header cell
    func otherUserProfileImage() -> UIImage {
        return UIImage()
    }
    
    func otherUserName() -> String {
        return trade.withUser!.firstName
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return cellModels.count
    }
    
    func tradePriceString() -> String {
        return trade.priceStringForUser(RemoteStore().currentUser()!)
    }
    
    func cellModelForRow(row: Int) -> TextbookTableViewCellModel {
        return cellModels[row]
    }
}
