//
//  TextbookTableViewCellModel.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/19/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TextbookTableViewCellModel: NSObject {
    let title: String
    let authors: String
    let price: String
    
    let textbookImage: MutableProperty<UIImage?> = MutableProperty(nil)
    
    private let textbookImageURL: String
    
    init(textbook: Textbook) {
        self.title = textbook.title
        self.authors = textbook.authorString
        self.price = textbook.formattedPrice
        self.textbookImageURL = textbook.mediumImageURL
        
        textbookImage <~ RemoteStore().imageWithURL(textbookImageURL)
            .on(failed: { print($0.localizedDescription) })
            .ignoreError()
        
        super.init()
    }
}
