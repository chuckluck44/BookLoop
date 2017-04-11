//
//  TradeDetailHeaderTableViewCell.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/13/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit

class TradeDetailHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var segmentedControl: XMSegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.segmentedControl.segmentTitle = ["YOU GET", "YOU GIVE"]
        self.segmentedControl.selectedItemHighlightStyle = XMSelectedItemHighlightStyle.bottomEdge
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
