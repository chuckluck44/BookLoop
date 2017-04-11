//
//  ChatsTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 11/1/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SVProgressHUD

let newChatNotification = "k_new_chat"
let reloadDistance: CGFloat = 10

class ChatsTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    fileprivate let store = RemoteStore()
    fileprivate var chats: [Chat] = []
    fileprivate var page = 0
    
    fileprivate var hasMorePrevious = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatsTableViewController.handleNewChat(_:)), name: NSNotification.Name(rawValue: newChatNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        self.hidesBottomBarWhenPushed = true
        
        loadChats()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification handling
    
    func handleNewChat(_ notification: Notification) {
        let user = notification.object as! User
        let chat = Chat(user: user)
        
        chats.insert(chat, at: 0)
        tableView.reloadData()
        
        //performSegueWithIdentifier("ChatSegue", sender: chat)
    }
    
    // MARK: - Remote store
    
    func loadChats() {
        SVProgressHUD.show()
        store.fetchChatsForCurrentUser(page) { [weak self] (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                return
            }
            SVProgressHUD.dismiss()
            
            self?.chats += result!
            self?.page += 1
            
            if result!.count < 10 {
                self?.hasMorePrevious = false
            }
            
            self?.tableView.reloadData()
        }
    }
    
    // MARK: Table view delegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasMorePrevious == false { return }
        
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height
        
        if y > h + reloadDistance {
            loadChats()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = self.chats[indexPath.row]
        self.performSegue(withIdentifier: "ChatSegue", sender: chat)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        
        let chat = self.chats[indexPath.row]
        
        cell.userLabel.text = chat.user.firstName
        
        if chat.lastMessage != nil {
            cell.lastMessageLabel.text = chat.lastMessage!.text
        } else {
            cell.lastMessageLabel.text = "No messages"
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Empty table view data source
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: "No Chats", attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12.0), NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: "Agree to a swap to start chatting", attributes: attributes)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! ChatViewController
        destinationController.chat = sender as! Chat
    }

}
