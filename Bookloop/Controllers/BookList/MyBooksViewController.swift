//
//  MyBooksViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/18/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SVProgressHUD
import DZNEmptyDataSet

class MyBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, XMSegmentedControlDelegate {
    @IBOutlet weak var segmentedControl: XMSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startSwappingButton: UIButton!
    

    private let viewModel = MyBooksViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        
        self.startSwappingButton.addTarget(self, action: #selector(test), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                 style: .Plain,
                                                                 target: self,
                                                                 action: #selector(handleEditButton))
        
        // Segmented Control
        self.segmentedControl.delegate = self
        self.segmentedControl.segmentTitle = viewModel.segmentTitle
        
        // Table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        
        self.tableView.registerNib(UINib(nibName: "TextbookTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTextbookCell")
        
        viewModel.refreshRequestsObserver.sendNext()
        viewModel.refreshOffersObserver.sendNext()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func test() {
        viewModel.test()
    }
    
    func bindViewModel() {
        
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext { [unowned self] in self.tableView.reloadData() }
        
        viewModel.alertMessageSignal
            .observeOn(UIScheduler())
            .observeNext { type in
                SVProgressHUD.show(type)
        }
    }
    
    // MARK: - UI actions
    
    func handleEditButton() {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
        
        self.navigationItem.rightBarButtonItem?.title = self.tableView.editing ? "Done" : "Edit"
    }
    
    // MARK: - Segmented control delegate
    
    func xmSegmentedControl(xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        viewModel.selectedIndex <~ MutableProperty(selectedSegment)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSectionsInTableView()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? viewModel.numberOfTextbooks() : 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyTextbookCell", forIndexPath: indexPath) as! TextbookTableViewCell
            let cellModel = viewModel.cellModelForRow(indexPath.row)
            cell.bindViewModel(cellModel)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddTextbookCell", forIndexPath: indexPath)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            self.performSegueWithIdentifier("ISBNLookupSegue", sender: nil)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            viewModel.deleteTextbookInRow(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
     }
    
    // MARK: - Empty table view data source
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text  = viewModel.titleForEmptyDataSet()
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let text  = viewModel.buttonTitleForEmptyDataSet()
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0)]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.performSegueWithIdentifier("ISBNLookupSegue", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ISBNLookupSegue" {
            let destinationModel = viewModel.isbnLookupViewModel()
            let destinationNavController = segue.destinationViewController as! UINavigationController
            let destinationController = destinationNavController.topViewController as! ISBNLookupTableViewController
            destinationController.setViewModel(destinationModel)
        }
    }
    
    @IBAction func unwindToMyBooks(segue: UIStoryboardSegue) {}

}
