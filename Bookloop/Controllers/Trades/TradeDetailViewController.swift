//
//  TradeDetailViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/13/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import SVProgressHUD
import PromiseKit
import PMKUIKit
import DZNEmptyDataSet

class TradeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, XMSegmentedControlDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var userHeaderView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: NSLayoutConstraint!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var segmentedControl: XMSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var showingRequests: Bool {
        return self.segmentedControl.selectedSegment == 0
    }
    
    var trade: TradeGroup!
    var store = RemoteStore()
    var networkRequestStatus = NetworkRequestStatus.none
    
    var matchedRequests: [TextbookRequest] = []
    var matchedOffers: [TextbookOffer] = []

    func layout(with trade: TradeGroup) {
        self.trade = trade
        self.store = RemoteStore()
        self.matchedRequests = trade.matchedRequestsByUser(store.currentUser()!)
        self.matchedOffers = trade.matchedOffersByUser(store.currentUser()!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TextbookTableViewCell", bundle: nil), forCellReuseIdentifier: "TradeDetailTextbookTableViewCell")
        
        self.segmentedControl.segmentTitle = ["YOU GET", "YOU GIVE"]
        self.segmentedControl.selectedItemHighlightStyle = XMSelectedItemHighlightStyle.bottomEdge
        self.segmentedControl.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        self.setTradeAndCancelButtonTitles()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.networkRequestStatus == .inProgress {
            SVProgressHUD.show()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setTradeAndCancelButtonTitles() {
        if self.trade.agreedTo {
            self.tradeButton.setTitle("Mark as completed", for: UIControlState.normal)
            self.cancelButton.setTitle("Cancel", for: UIControlState.normal)
        } else {
            self.tradeButton.setTitle("Accept trade", for: UIControlState.normal)
            self.cancelButton.setTitle("Reject", for: UIControlState.normal)
        }
    }
    
    // Mark: - UI Handling
    
    func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        tableView.reloadData()
    }

    @IBAction func handleMessageButton(_ sender: AnyObject) {
        self.tabBarController?.selectedIndex = 2
        NotificationCenter.default.post(name: Notification.Name(rawValue: newChatNotification), object: trade.withUser)
    }
    
    @IBAction func handleTradeButton(_ sender: AnyObject) {
        if !self.trade.agreedTo {
            self.handleNetworkRequest(self.store.agreeTo, sender: self.tradeButton, success: {
                self.trade.tradeStatus.update(with: .currentUserAgreed)
            })
        } else {
            self.handleNetworkRequest(self.store.confirm, sender: self.tradeButton, success: {
                self.trade.tradeStatus.update(with: .currentUserAgreed)
            })
        }
    }
    
    @IBAction func handleCancelButton(_ sender: AnyObject) {
        if !self.trade.agreedTo {
            self.handleNetworkRequest(self.store.decline, sender: self.cancelButton, success: {})
        } else {
            self.handleNetworkRequest(self.store.cancel, sender: self.cancelButton, success: {
                self.trade.tradeStatus.subtract(.currentUserAgreed)
            })
        }
        
    }

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showingRequests ? matchedRequests.count : matchedOffers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textbook = self.showingRequests ? matchedRequests[indexPath.row].textbook : matchedOffers[indexPath.row].textbook
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradeDetailTextbookTableViewCell", for: indexPath) as! TextbookTableViewCell
        cell.layout(with: textbook)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: - Empty table view data source
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: "No Textbooks", attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.darkGray]

        return NSAttributedString(string: "", attributes: attributes)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func handleNetworkRequest(_ request: @escaping (TradeGroup)->Promise<Bool>, sender: UIButton, success: @escaping ()->() ) {
        self.tradeButton.isEnabled = false
        self.cancelButton.isEnabled = false
        
        let alert = self.alertControllerForCurrentTradeStatus(for: sender)
        self.promise(alert, animated: true, completion: nil).then { _ -> Promise<Bool> in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            SVProgressHUD.show()
            self.networkRequestStatus = .inProgress
            return request(self.trade)
        }.always {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
            self.tradeButton.isEnabled = true
            self.cancelButton.isEnabled = true
        }.then { _ -> Void in
            self.networkRequestStatus = .succeeded
            success()
            self.setTradeAndCancelButtonTitles()
        }.catch {
            self.networkRequestStatus = .failed
            SVProgressHUD.showError(withStatus: $0.localizedDescription)
        }
    }
    
    func alertControllerForCurrentTradeStatus(for sender: UIButton) -> PMKAlertController {
        var alertTitle = "Agree to trade"
        var alertMessage = "Are you sure you want to agree to this trade?"
        var actionTitle = "Agree"
        var cancelTitle = "Cancel"
        var actionStyle = UIAlertActionStyle.default
        
        if sender == self.tradeButton {
            if self.trade.agreedTo {
                alertTitle = "Confirm trade completed"
                alertMessage = "Are you sure you want to mark this trade as completed?"
                actionTitle = "Confirm"
            }
        } else {
            if self.trade.agreedTo {
                alertTitle = "Cancel trade"
                alertMessage = "Are you sure you want to cancel this trade?"
                cancelTitle = "Cancel"
                actionTitle = "Cancel trade"
                actionStyle = .destructive
            } else {
                alertTitle = "Reject trade"
                alertMessage = "Are you sure you want to reject this trade? This cannot be undone."
                cancelTitle = "Cancel"
                actionTitle = "Reject trade"
                actionStyle = .destructive
            }
        }

        let alertController = PMKAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addActionWithTitle(title: cancelTitle, style: .cancel)
        alertController.addActionWithTitle(title: actionTitle, style: actionStyle)
        
        return alertController
    }
}
