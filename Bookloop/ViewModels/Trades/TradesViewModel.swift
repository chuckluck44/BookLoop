//
//  TradesViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError
import Parse

class TradesViewModel: NSObject {
    
    // Input
    let refreshObserver: Observer<Void, NoError>
    
    // Output
    let contentChangesSignal: Signal<(), NoError>
    let alertMessageSignal: Signal<AlertType, NoError>
    let isLoading = MutableProperty(false)
    
    private var trades: [TradeGroup]
    private let store = RemoteStore()
    private let contentChangesObserver: Observer<(), NoError>
    private let alertMessageObserver: Observer<AlertType, NoError>
    
    override init() {
        self.trades = []
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let (contentChangesSignal, contentChangesObserver) = Signal<(), NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AlertType, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        
        super.init()
        
        SignalProducer(signal: refreshSignal)
            .on(started: { [unowned self] _ in self.isLoading.value = true })
            .flatMap(.Merge) {[unowned self] _ in
                return self.store.tradesForCurrentUser()
                    .collect()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(.Error(message: error.localizedDescription))
                        return SignalProducer(value: [])
                    }
            }
            .startWithNext { [unowned self] trades in
                self.isLoading.value = false
                if trades.count > 0 {
                    self.trades = trades
                    contentChangesObserver.sendNext()
                }
            }
    }
    
    func numberOfTradesInSection(section: Int) -> Int {
        return trades.count
    }
    
    // Table cell methods
    func userBalanceString() -> String {
        let balance = 0.0
        return "BALANCE: \(balance)"
    }
    
    func userProfilePictureForRow(row: Int) -> UIImage {
        return UIImage()
    }
    
    func tradeSummaryForRow(row: Int) -> String {
        let trade = trades[row]
        return "\(trade.matches.count) books in trade"
    }
    
    func tradeDetailsForRow(row: Int) -> String {
        let trade = trades[row]
        let dateString = DateFormatHelper().timeAgoSinceDate(trade.createdAt)
        return "\(trade.withUser!.firstName) - \(dateString)"
    }
    
    func tradePointCostForRow(row: Int) -> String {
        let trade = trades[row]
        let cost = trade.pointCostForUser(store.currentUser()!)
        return priceStringFromInteger(cost)
    }
    
    func tradeDetailViewModelForIndexPath(indexPath: NSIndexPath) -> TradeDetailViewModel {
        let trade = trades[indexPath.row]
        let currentUser = store.currentUser()!
        return TradeDetailViewModel(trade: trade, currentUser: currentUser)
    }
    
    // Helper
    func priceStringFromInteger(value: Int) -> String {
        let dollars = value/100
        let cents = abs(value%100)
        return "\(dollars).\(cents)"
    }
}
