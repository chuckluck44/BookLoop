//
//  TradeDetailViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/13/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SVProgressHUD

class TradeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMSegmentedControlDelegate {
    @IBOutlet weak var userHeaderView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: NSLayoutConstraint!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var segmentedControl: XMSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tradeButton: UIButton!
    
    private var viewModel: TradeDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViewModel()
        
        tableView.registerNib(UINib(nibName: "TextbookTableViewCell", bundle: nil), forCellReuseIdentifier: "TradeDetailTextbookTableViewCell")
        
        self.segmentedControl.segmentTitle = ["YOU GET", "YOU GIVE"]
        self.segmentedControl.selectedItemHighlightStyle = XMSelectedItemHighlightStyle.BottomEdge
        self.segmentedControl.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setViewModel(viewModel: TradeDetailViewModel) {
        self.viewModel = viewModel
    }
    
    func bindViewModel() {
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext { [unowned self] in self.tableView.reloadData() }
        
        viewModel.alertMessageSignal
            .observeNext { type in
                SVProgressHUD.show(type)
        }
        
    }
    
    // Segmented Control
    func xmSegmentedControl(xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        viewModel.selectedIndex <~ MutableProperty(selectedSegment)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellModel = viewModel.cellModelForRow(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("TradeDetailTextbookTableViewCell", forIndexPath: indexPath) as! TextbookTableViewCell
        cell.bindViewModel(cellModel)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
