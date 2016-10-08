//
//  ISBNLookupTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/18/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SVProgressHUD

class ISBNLookupTableViewController: UITableViewController {
    @IBOutlet weak var ISBNTextField: UITextField!
    @IBOutlet weak var addTextbookButton: UIButton!

    private var viewModel: ISBNLookupViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setViewModel(viewModel: ISBNLookupViewModel) {
        self.viewModel = viewModel
    }
    
    func bindViewModel() {
        
        // Text fields
        self.viewModel.ISBN <~ self.ISBNTextField.rac_textSignal().toSignalProducer()
            .ignoreError()
            .map { text in text as! String }
        
        
        // Login Action
        self.addTextbookButton.rex_pressed.value = self.viewModel.textbookLookupAction.unsafeCocoaAction
        
        // Navigation
        self.viewModel.textbookResult
            .producer
            .startWithNext { [weak self] textbook in
                if textbook != nil {
                    self!.performSegueWithIdentifier("TextbookResultSegue", sender: nil)
                }
            }
        
        // Progress alerts
        self.viewModel.alertMessageSignal
            .observeNext { type in
                SVProgressHUD.show(type)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TextbookResultSegue" {
            let destinationModel = viewModel.textbookResultViewModel()
            let destinationController = segue.destinationViewController as! TextbookResultTableViewController
            
            destinationController.setViewModel(destinationModel)
        }
    }

    @IBAction func unwindToISBNLookup(segue: UIStoryboardSegue) {}
}
