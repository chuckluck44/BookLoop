//
//  ButtonTableViewCell.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/20/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
