//
//  TextbookTableViewCell.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/9/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TextbookTableViewCell: UITableViewCell {
    @IBOutlet weak var textbookImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    let imageWasFetched = MutableProperty(false)
    
    private var viewModel: TextbookTableViewCellModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindViewModel(viewModel: TextbookTableViewCellModel) {
        self.viewModel = viewModel
        
        self.titleLabel.text = viewModel.title
        self.conditionLabel.text = viewModel.authors
        self.priceLabel.text = viewModel.price
        
        viewModel.textbookImage.producer
            .takeUntil(self.racutil_prepareForReuseProducer)
            .filter { $0 != nil }
            .startWithNext { [unowned self] image in
                self.textbookImage.image = image
                self.imageWasFetched.value = true
            }
    }

}
