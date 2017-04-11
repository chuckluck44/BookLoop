//
//  TradeTableViewCell.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit

class TradeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tradeSummaryLabel: UILabel!
    @IBOutlet weak var tradeDetailsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    let store = RemoteStore()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func layout(with trade: TradeGroup) {
        self.tradeSummaryLabel.text = "\(trade.matches.count) books in trade"
        
        let dateString = trade.createdAt.friendlyIntervalToNow()
        self.tradeDetailsLabel.text = "\(trade.withUser.firstName) - \(dateString)"
        
        let cost = trade.pointCostForUser(store.currentUser()!)
        self.pointsLabel.text = priceStringFromInteger(cost)
    }
    
    
    
    func userProfilePictureForRow(_ row: Int) -> UIImage {
        return UIImage()
    }
    
    func priceStringFromInteger(_ value: Int) -> String {
        let dollars = value/100
        let cents = abs(value%100)
        return "\(dollars).\(cents)"
    }
}
