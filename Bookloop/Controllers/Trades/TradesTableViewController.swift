//
//  TradesTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Rex
import SVProgressHUD

class TradesTableViewController: UITableViewController {
    
    private let viewModel = TradesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        tableView.registerNib(UINib(nibName: "TradeTableViewCell", bundle: nil), forCellReuseIdentifier: "TradeTableViewCell")
        
        self.refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(handleRefreshControl), forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindViewModel() {
        self.rex_viewWillAppear.observe(viewModel.refreshObserver)
        
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext { [unowned self] in self.tableView.reloadData() }
        
        viewModel.isLoading.producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl?.endRefreshing()
                }
            }
        
        viewModel.alertMessageSignal
            .observeNext { type in
                SVProgressHUD.show(type)
            }
        
    }
    
    func handleRefreshControl() {
        viewModel.refreshObserver.sendNext()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.numberOfTradesInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BalanceTableViewCell", forIndexPath: indexPath) as! BalanceTableViewCell
            
            cell.userBalanceLabel.text = viewModel.userBalanceString()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TradeTableViewCell", forIndexPath: indexPath) as! TradeTableViewCell
            
            cell.tradeSummaryLabel.text = viewModel.tradeSummaryForRow(indexPath.row)
            cell.tradeDetailsLabel.text = viewModel.tradeDetailsForRow(indexPath.row)
            cell.pointsLabel.text = viewModel.tradePointCostForRow(indexPath.row)
            
            return cell
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40
        } else {
            return 76.5
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("TradeDetailSegue", sender: indexPath)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TradeDetailSegue" {
            let tradeDetailViewModel = viewModel.tradeDetailViewModelForIndexPath(sender as! NSIndexPath)
            let destinationViewControlller = segue.destinationViewController as! TradeDetailViewController
            destinationViewControlller.setViewModel(tradeDetailViewModel)
            destinationViewControlller.bindViewModel()
        }
    }
}
