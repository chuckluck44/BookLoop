//
//  MyBooksViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/18/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse
import ReactiveSwift
import enum Result.NoError

class MyBooksViewModel: NSObject {
    
    // Input
    let selectedIndex = MutableProperty(0)
    
    // Input signals
    let refreshRequestsObserver: Observer<Void, NoError>
    let refreshOffersObserver: Observer<Void, NoError>
    
    // Output
    let segmentTitle = ["I NEED", "I HAVE"]
    
    // Output signals
    let contentChangesSignal: Signal<(), NoError>
    let alertMessageSignal: Signal<AlertType, NoError>
    
    // Data Model
    fileprivate var textbookRequests: [TextbookRequest]
    fileprivate var textbookOffers: [TextbookOffer]
    fileprivate var cellModels: [TextbookTableViewCellModel]
    
    // Store request status
    fileprivate let store = RemoteStore()
    fileprivate let requestFetchStatus: MutableProperty<StoreRequestStatusType> = MutableProperty(.none)
    fileprivate let offerFetchStatus: MutableProperty<StoreRequestStatusType> = MutableProperty(.none)
    
    // Observers
    fileprivate let contentChangesObserver: Observer<(), NoError>
    fileprivate let alertMessageObserver: Observer<AlertType, NoError>
    
    override init() {
        self.textbookRequests = []
        self.textbookOffers = []
        self.cellModels = []
        
        let (refreshRequestsSignal, refreshRequestsObserver) = Signal<Void, NoError>.pipe()
        self.refreshRequestsObserver = refreshRequestsObserver
        
        let (refreshOffersSignal, refreshOffersObserver) = Signal<Void, NoError>.pipe()
        self.refreshOffersObserver = refreshOffersObserver
        
        let (contentChangesSignal, contentChangesObserver) = Signal<(), NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let (alertMessageSignal, alertMessageObserver) = Signal<AlertType, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        super.init()
        
        // Fetch Textbook Requests
        SignalProducer(signal: refreshRequestsSignal)
            .on(next: { [unowned self] _ in self.requestFetchStatus.value = .inProgress })
            .flatMap(.merge) {[unowned self] _ in
                return self.store.textbookRequestsForCurrentUser()
                    .collect()
                    .flatMapError { error in
                        self.requestFetchStatus.value = .failed(error: error)
                        return SignalProducer(value: [])
                    }
                    .on(completed: { [unowned self] _ in self.requestFetchStatus.value = .succeeded })
            }
            .startWithNext { [unowned self] requests in
                guard requests.count > 0 else { return }
                self.textbookRequests = requests
                self.cellModels = requests.map { request in TextbookTableViewCellModel(textbook: request.textbook) }
                contentChangesObserver.sendNext()
            }
        
        // Fetch Textbook Offers
        SignalProducer(signal: refreshOffersSignal)
            .on(next: { [unowned self] _ in self.offerFetchStatus.value = .inProgress })
            .flatMap(.merge) {[unowned self] _ in
                return self.store.textbookOffersForCurrentUser()
                    .collect()
                    .flatMapError { error in
                        self.offerFetchStatus.value = .failed(error: error)
                        return SignalProducer(value: [])
                    }
                    .on(completed: { [unowned self] _ in self.offerFetchStatus.value = .succeeded })
            }
            .startWithNext { [unowned self] offers in
                guard offers.count > 0 else { return }
                self.textbookOffers = offers
                self.cellModels = offers.map { offer in TextbookTableViewCellModel(textbook: offer.textbook) }
                contentChangesObserver.sendNext()
            }
        
        // Alerts based on store request status
        combineLatest(selectedIndex.producer, requestFetchStatus.producer, offerFetchStatus.producer)
            .map { return $0 == 0 ? $1 : $2 }
            .skipRepeats{ (status1, status2) in status1 == status2 }
            .startWithNext { [unowned self] status in alertMessageObserver.sendNext(self.alertMapping(status)) }
        
        
        
        // Selected Segment changed
        self.selectedIndex
            .producer
            .startWithNext { [unowned self] index in
                if index == 0 {
                    self.cellModels = self.textbookRequests.map { request in TextbookTableViewCellModel(textbook: request.textbook) }
                } else {
                    self.cellModels = self.textbookOffers.map { offer in TextbookTableViewCellModel(textbook: offer.textbook) }
                }
                contentChangesObserver.sendNext()
        }
        
    }
    
    func test () {
        let parseRequestObjects = self.textbookRequests.map { request in PFObject(withoutDataWithClassName: "TextbookRequest", objectId: request.id!) }
        let parseOfferObjects = self.textbookRequests.map { offer in PFObject(withoutDataWithClassName: "TextbookOffer", objectId: offer.id!) }
        PFCloud.callFunction(inBackground: "findMatchesForCurrentUser", withParameters: nil) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(response as! String)
            }
        }
    }
    
    // Table view
    func numberOfSectionsInTableView() -> Int {
        return cellModels.count > 0 ? 2 : 0
    }
    
    func numberOfTextbooks() -> Int {
        return cellModels.count
    }
    
    func cellModelForRow(_ row: Int) -> TextbookTableViewCellModel {
        return cellModels[row]
    }
    
    func deleteTextbookInRow(_ row: Int) {
        if selectedIndex.value == 0 {
            store.deleteTextbookRequest(self.textbookRequests[row])
            textbookRequests.remove(at: row)
            cellModels.remove(at: row)
        } else {
            store.deleteTextbookOffer(self.textbookOffers[row])
            textbookOffers.remove(at: row)
            cellModels.remove(at: row)
        }
    }
    
    // Empty table view
    func titleForEmptyDataSet() -> String {
        return self.selectedIndex.value == 0 ? "No textbooks requested" : "No textbooks offered"
    }
    
    func buttonTitleForEmptyDataSet() -> String {
        return self.selectedIndex.value == 0 ? "Request textbooks" : "Offer textbooks"
    }
    
    
    // Child view model
    func isbnLookupViewModel() -> ISBNLookupViewModel {
        let requesting = selectedIndex.value == 0
        return ISBNLookupViewModel(requesting: requesting)
    }
    
    // Helpers
    
    func alertMapping(_ status: StoreRequestStatusType) -> AlertType {
        switch status {
        case .inProgress:
            return .default
        case let .failed(error: error):
            return .error(message: error.localizedDescription)
        case .succeeded:
            return .dismiss
        case .none:
            return .ignore
        }
    }
}
