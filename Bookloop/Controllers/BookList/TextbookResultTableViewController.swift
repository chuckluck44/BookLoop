//
//  TextbookResultTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/18/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit

class TextbookResultTableViewController: UITableViewController {
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var frontCoverImageView: UIImageView!
    @IBOutlet weak var ISBN13Label: UILabel!
    @IBOutlet weak var ISBN10Label: UILabel!

    private var textbook: Textbook?
    var requesting: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func layout(with textbook: Textbook) {
        self.textbook = textbook
        self.titleLabel.text = textbook.title
        self.authorsLabel.text = textbook.authorString
        self.editionLabel.text = textbook.edition
        self.ISBN10Label.text = textbook.ISBN
        self.ISBN13Label.text = textbook.EAN
        
        self.frontCoverImageView.downloadAsync(fromURL: textbook.mediumImageURL)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TextbookConditionSegue" {
            let destinationController = segue.destination as! TextbookConditionTableViewController
            destinationController.textbook = self.textbook
            destinationController.requesting = self.requesting
        }
    }

}
