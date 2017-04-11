//
//  MyBooksViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/18/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveSwift
import SVProgressHUD
import DZNEmptyDataSet

class MyBooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, XMSegmentedControlDelegate {
    @IBOutlet weak var segmentedControl: XMSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    var showingRequests: Bool {
        return self.segmentedControl.selectedSegment == 0
    }
    
    let store = RemoteStore()
    
    // Binding Flags
    let textbookRequestNRS = MutableProperty(NetworkRequestStatus.none)
    let textbookOfferNRS = MutableProperty(NetworkRequestStatus.none)
    let allTextbookRequestsArePublic = MutableProperty(true)
    let allTextbookOffersArePublic = MutableProperty(true)
    
    // Data Source
    var textbookRequests: [TextbookRequest] = []
    var textbookOffers: [TextbookOffer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.startSwappingButton.addTarget(self, action: #selector(test), for: UIControlEvents.touchUpInside)
        
        // Segmented Control
        self.segmentedControl.delegate = self
        self.segmentedControl.segmentTitle = ["I NEED", "I HAVE"]
        
        // Table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.tableFooterView = UIView()
        
        self.tableView.register(UINib(nibName: "TextbookTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTextbookCell")
        
        self.bindUserInterface()
        
        self.loadTextbookRequests()
        self.loadTextbookOffers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindUserInterface() {
        
        // Alerts
        self.textbookRequestNRS.producer.startWithValues { status in
            if self.showingRequests {
                self.showAlert(with: status)
            }
        }
        self.textbookRequestNRS.producer.startWithValues { status in
            if !self.showingRequests {
                self.showAlert(with: status)
            }
        }
        
        self.startButton.reactive.isHidden <~ self.allTextbookRequestsArePublic.producer
            .combineLatest(with: self.allTextbookOffersArePublic.producer)
            .map { $0 &&  $1 }
    }
    
    // MARK: - Network Requests
    
    func loadTextbookRequests() {
        self.textbookRequestNRS.value = .inProgress
        store.getTextbookRequestsForCurrentUser().then { results -> Void in
            self.textbookRequestNRS.value = .succeeded
            self.textbookRequests = results
            self.allTextbookRequestsArePublic.value = results.filterNotPublic().count == 0
            self.tableView.reloadData()
        }.catch { _ in self.textbookRequestNRS.value = .failed }
    }
    
    func loadTextbookOffers() {
        self.textbookOfferNRS.value = .inProgress
        store.getTextbookOffersForCurrentUser().then { results -> Void in
            self.textbookOfferNRS.value = .succeeded
            self.textbookOffers = results
            self.allTextbookOffersArePublic.value = results.filterNotPublic().count == 0
            self.tableView.reloadData()
        }.catch { _ in self.textbookOfferNRS.value = .failed }
    }
    
    // MARK: - UI handling
    
    func xmSegmentedControl(_ xmSegmentedControl: XMSegmentedControl, selectedSegment: Int) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "textbookDetailSegue", sender: indexPath.row)
    }
    
    @IBAction func handleStartButton(_ sender: Any) {
        self.startButton.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show()
        
        store.publicizeRequests(self.textbookRequests.filterNotPublic(), andOffers: self.textbookOffers.filterNotPublic()).then { _ in
            return self.store.findMatchesForCurrentUser()
        }.always {
            self.startButton.isEnabled = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.dismiss()
        }.catch {
            SVProgressHUD.showError(withStatus: $0.localizedDescription)
        }
    }

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.segmentedControl.selectedSegment == 0 ? self.textbookRequests.count : self.textbookOffers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textbook = self.textbook(forRow: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTextbookCell", for: indexPath) as! TextbookTableViewCell
        cell.layout(with: textbook)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: - Empty table view data source
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text  = self.segmentedControl.selectedSegment == 0 ? "No textbooks requested" : "No textbooks offered"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let text  = self.segmentedControl.selectedSegment == 0 ? "Request textbooks" : "Offer textbooks"
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0)]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.performSegue(withIdentifier: "ISBNLookupSegue", sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ISBNLookupSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationController = destinationNavigationController.topViewController as! ISBNLookupTableViewController
            
            destinationController.requesting = self.segmentedControl.selectedSegment == 0
            
        } else if segue.identifier == "textbookDetailSegue" {
            let destinationController = segue.destination as! TextbookDetailTableViewController
            
            if self.showingRequests {
                destinationController.request = self.textbookRequests[sender as! Int]
            } else {
                destinationController.offer = self.textbookOffers[sender as! Int]
            }
            
            destinationController.removeTextbookButtonHidden = false
        }
    }
    
    @IBAction func unwindToMyBooks(_ segue: UIStoryboardSegue) {}
    
    // MARK: - Alerts
    
    func showAlert(with status: NetworkRequestStatus) {
        switch status {
        case .inProgress:
            SVProgressHUD.show()
        case .succeeded:
            SVProgressHUD.dismiss()
        case .failed:
            SVProgressHUD.showError(withStatus: "")
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    func textbook(forRow row: Int) -> Textbook {
        if self.segmentedControl.selectedSegment == 0 {
            return self.textbookRequests[row].textbook
        } else {
            return self.textbookOffers[row].textbook
        }
    }
}
