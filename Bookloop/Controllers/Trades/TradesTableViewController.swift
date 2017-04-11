//
//  TradesTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/31/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SVProgressHUD

class TradesTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var trades: [TradeGroup] = []
    let store = RemoteStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "TradeTableViewCell", bundle: nil), forCellReuseIdentifier: "TradeTableViewCell")
        
        self.refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(handleRefreshControl), for: UIControlEvents.valueChanged)
        
        refreshControl?.beginRefreshing()
        loadTrades()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefreshControl() {
        loadTrades()
    }
    
    // MARK: - Remote Store
    
    func loadTrades() {
        store.getTradesForCurrentUser().then { result -> Void in
            self.refreshControl?.endRefreshing()
            self.trades = result 
            self.tableView.reloadData()
        }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : trades.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceTableViewCell", for: indexPath) as! BalanceTableViewCell
            
            cell.userBalanceLabel.text = userBalanceString()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTableViewCell", for: indexPath) as! TradeTableViewCell
            
            cell.layout(with: trades[indexPath.row])
            
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 0
        } else {
            return 76.5
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "TradeDetailSegue", sender: trades[indexPath.row])
    }
    
    // MARK: - Empty table view data source
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: "No Swaps Available", attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: "Swaps will appear here when you are matched", attributes: attributes)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TradeDetailSegue" {
            let destinationViewControlller = segue.destination as! TradeDetailViewController
            destinationViewControlller.layout(with: sender as! TradeGroup)
        }
    }
    
    // MARK: - Formatters
    
    func userBalanceString() -> String {
        let balance = 0.0
        return "BALANCE: \(balance)"
    }
    
    
}
