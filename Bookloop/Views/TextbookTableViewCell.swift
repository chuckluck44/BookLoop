//
//  TextbookTableViewCell.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/9/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class TextbookTableViewCell: UITableViewCell {
    @IBOutlet weak var textbookImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layout(with textbook: Textbook) {
        self.authorLabel.text = textbook.authorString
        self.titleLabel.text = textbook.title
        self.editionLabel.text = "Edition: " + textbook.edition
        self.conditionLabel.text = BLStringFormatter.conditionString(for: .likeNew)
        self.priceLabel.text = textbook.priceString()
        
        self.textbookImage.downloadAsync(fromURL: textbook.smallImageURL)
    }
}
