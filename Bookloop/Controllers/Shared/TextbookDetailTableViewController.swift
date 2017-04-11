//
//  TextbookDetailTableViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 12/9/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import SVProgressHUD

class TextbookDetailTableViewController: UITableViewController {
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var textbookImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionDetailLabel: UILabel!
    @IBOutlet weak var ISBNLabel: UILabel!
    @IBOutlet weak var EANLabel: UILabel!
    
    @IBOutlet weak var removeTextbookTableViewCell: UITableViewCell!
    

    var removeTextbookButtonHidden = true
    
    var request: TextbookRequest?
    var offer: TextbookOffer?
    let store = RemoteStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        var textbook: Textbook!
        var condition: TextbookCondition!
        if request != nil {
            textbook = self.request!.textbook
            condition = self.request!.minimumCondition
        } else {
            textbook = self.offer!.textbook
            condition = self.offer!.condition
        }
        
        self.titleLabel.text = textbook.title
        self.authorsLabel.text = textbook.authorString
        self.editionLabel.text = "Edition: " + textbook.edition
        self.conditionLabel.text = BLStringFormatter.conditionString(for: condition)
        self.conditionDetailLabel.text = BLStringFormatter.conditionDetailString(for: condition)
        self.ISBNLabel.text = textbook.ISBN
        self.EANLabel.text = textbook.EAN
        
        self.textbookImageView.downloadAsync(fromURL: textbook!.mediumImageURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            SVProgressHUD.show()
            if self.request != nil {
                store.delete(self.request!).then { _ -> Void in
                    SVProgressHUD.dismiss()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "TextbookRequestWasDeleted"), object: self.request)
                }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
            } else {
                store.delete(self.offer!).then { _ -> Void in
                    SVProgressHUD.dismiss()
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "TextbookOfferWasDeleted"), object: self.offer)
                }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return indexPath.row == 0 ? 100 : 200
        } else if indexPath.section == 3 {
            return self.removeTextbookButtonHidden ? 0 : 40
        } else {
            return 40
        }
    }

}
