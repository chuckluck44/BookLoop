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

    var requesting: Bool?
    var textbook: Textbook?
    
    var condition: TextbookCondition = .likeNew
    
    private let store = RemoteStore()
    
    // MARK: - UI Handling
    
    @IBAction func handleDoneButton(_ sender: Any) {
        SVProgressHUD.show()
        if requesting! {
            store.request(textbook!, condition: condition).then { _ in
                SVProgressHUD.dismiss()
                
            }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
        } else {
            store.offer(textbook!, condition: condition).then { _ -> Void in
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "unwindToISBNLookupSegue", sender: nil)
            }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let numberOfRows = tableView.numberOfRows(inSection: section)
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                cell.accessoryType = row == indexPath.row ? .checkmark : .none
            }
        }
        self.condition = TextbookCondition(rawValue: indexPath.row)!
    }

}
