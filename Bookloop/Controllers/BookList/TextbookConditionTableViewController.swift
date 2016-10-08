//
//  TextbookConditionTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/19/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import SVProgressHUD
import ReactiveCocoa

class TextbookConditionTableViewController: UITableViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!

    private var viewModel: TextbookConditionViewModel!
    
    /*
    lazy var textbookRequestCocoaAction: CocoaAction = { _ in
        CocoaAction(viewModel.textbookRequestAction) { value in
        value as! UIBarButtonItem
    }()
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    func setViewModel(viewModel: TextbookConditionViewModel) {
        self.viewModel = viewModel
    }
    
    func bindViewModel() {
        
        self.doneButton.rex_action.value = viewModel.addTextbookAction.unsafeCocoaAction
        
        viewModel.alertMessageSignal
            .observeNext { type in
                SVProgressHUD.show(type)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let numberOfRows = tableView.numberOfRowsInSection(section)
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
                cell.accessoryType = row == indexPath.row ? .Checkmark : .None
            }
        }
        viewModel.condition = indexPath.row
    }

}
