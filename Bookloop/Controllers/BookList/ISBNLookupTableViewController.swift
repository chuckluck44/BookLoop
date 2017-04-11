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

    let store = RemoteStore()
    
    var requesting: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Handling
    
    @IBAction func handleAddTextbookButton(_ sender: Any) {
        let isbn = self.ISBNTextField.text!
        if isbn.characters.count != 10 && isbn.characters.count != 13 {
            SVProgressHUD.showError(withStatus: "ISBN must be 10 or 13 digits long")
            return
        }
        
        SVProgressHUD.show()
        store.getTextbook(withISBN: isbn, success: { textbook in
            if textbook != nil {
                self.performSegue(withIdentifier: "TextbookResultSegue", sender: textbook!)
            } else {
                SVProgressHUD.showError(withStatus: "No textbooks match this ISBN")
            }
        }, failure: { SVProgressHUD.showError(withStatus: $0.localizedDescription) })
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TextbookResultSegue" {
            let destinationController = segue.destination as! TextbookResultTableViewController
            destinationController.layout(with: sender as! Textbook)
        }
    }

    @IBAction func unwindToISBNLookup(_ segue: UIStoryboardSegue) {}
}
