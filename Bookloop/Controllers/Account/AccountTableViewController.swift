//
//  AccountTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 12/9/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import SVProgressHUD

class AccountTableViewController: UITableViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!

    let store = RemoteStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleNotificationsSwitch(_ sender: Any) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            self.logOut()
        }
    }
    
    func logOut() {
        store.logOut().then { _ -> Void in
            let notification = Notification(name: Notification.Name(userDidLogOutNotification))
            NotificationCenter.default.post(notification)
        }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
    }

}
