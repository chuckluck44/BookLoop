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

    private var viewModel: TextbookResultViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setViewModel(viewModel: TextbookResultViewModel) {
        self.viewModel = viewModel
    }
    
    func bindViewModel() {
        
        self.titleLabel.text = viewModel.title
        self.authorsLabel.text = viewModel.authors
        self.editionLabel.text = viewModel.edition
        self.ISBN10Label.text = viewModel.ISBN10
        self.ISBN13Label.text = viewModel.ISBN13
        
        viewModel.textbookImageSignal
            .ignoreError()
            .filter { $0 != nil }
            .startWithNext { [unowned self] image in
                self.frontCoverImageView.image = image
                self.tableView.reloadData()
            }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TextbookConditionSegue" {
            let destinationModel = viewModel.textbookConditionViewModel()
            let destinationController = segue.destinationViewController as! TextbookConditionTableViewController
            destinationController.setViewModel(destinationModel)
        }
    }

}
