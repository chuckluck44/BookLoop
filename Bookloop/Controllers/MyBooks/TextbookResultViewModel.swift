//
//  TextbookResultViewModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/18/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import enum Result.NoError

class TextbookResultViewModel: NSObject {
    
    let title: String
    let authors: String
    let edition: String
    let ISBN10: String
    let ISBN13: String
    
    let textbookImageSignal: SignalProducer<UIImage?, NSError>!
    
    fileprivate let textbookImageURL: String
    fileprivate let textbook: Textbook
    fileprivate let requesting: Bool

    init(textbook: Textbook, requesting: Bool) {
        self.textbook = textbook
        self.requesting = requesting
        
        self.title = textbook.title
        self.authors = textbook.authorString
        self.edition = textbook.edition
        self.ISBN10 = textbook.ISBN
        self.ISBN13 = textbook.EAN
        self.textbookImageURL = textbook.mediumImageURL
        
        self.textbookImageSignal = RemoteStore().imageWithURL(textbookImageURL)
            .on(failed: { print($0.localizedDescription) })
        
        super.init()
    }
    
    func textbookConditionViewModel() -> TextbookConditionViewModel {
        return TextbookConditionViewModel(textbook: textbook, requesting: requesting)
    }
}
