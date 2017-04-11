//
//  Textbook.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse

enum TextbookCondition: Int {
    case likeNew = 0, great, good, poor
}

class Textbook: BLObject {
    let title: String
    let authors: [String]
    let ISBN: String
    let EAN: String
    let edition: String
    let price: Int
    let formattedPrice: String
    let mediumImageURL: String
    let smallImageURL: String
    
    var smallImage: UIImage?
    var mediumImage: UIImage?

    var authorString: String {
        get {
            return authors.reduce("") { T, author in
                T+author+","
            }
        }
    }
    
    init(parseObject: PFObject) {
        
        self.title = parseObject["title"] as! String
        self.authors = parseObject["authors"] as! [String]
        self.ISBN = parseObject["ISBN"] as! String
        self.EAN = parseObject["EAN"] as! String
        self.edition = parseObject["edition"] as! String
        self.price = parseObject["price"] as! Int
        self.formattedPrice = parseObject["formattedPrice"] as! String
        self.mediumImageURL = parseObject["mediumImageURL"] as! String
        self.smallImageURL = parseObject["smallImageURL"] as! String
        
        super.init()
        
        self.id = parseObject.objectId!
        self.parseClassName = "Textbook"
    }
    
    func priceString() -> String {
        let dollars = price/100
        let cents = abs(price%100)
        return "\(dollars).\(cents)"
    }
}
