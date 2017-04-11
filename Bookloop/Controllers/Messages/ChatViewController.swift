//
//  ChatViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 11/1/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import JSQMessagesViewController
import UIKit
import SVProgressHUD

class ChatViewController: JSQMessagesViewController {
    
    var chat: Chat!
    
    var messages = [Message]()
    //var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var displayName: String!
    
    let store: RemoteStore = RemoteStore()
    var hasMorePrevious: Bool = true
    var page: Int = 0
    
    override var senderId: String! {
        get { return self.store.currentUser()!.id }
        set { self.senderId = newValue }
    }
    
    override var senderDisplayName: String! {
        get { return self.store.currentUser()!.firstName }
        set { self.senderDisplayName = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.lightGray)
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
    // MARK: - Remote store
    
    func loadMessages() {
        SVProgressHUD.show()
        /*
        RemoteStore().fetchMessagesInChat(chat, page: page) { [weak self] (result: [Message]?, error) in
            if error != nil {
                SVProgressHUD.showErrorWithStatus(error?.localizedDescription)
                return
            }
            SVProgressHUD.dismiss()
            
            let newMessages = result!.map { message in JSQMessage(senderId: message.sender.id, senderDisplayName: message.sender.firstName, date: message.createdAt, text: message.content)! }
            self?.messages += newMessages
            self?.page += 1
            
            if result!.count < 10 {
                self?.hasMorePrevious = false
            }
            
            self?.collectionView?.reloadData()
            self?.collectionView?.layoutIfNeeded()
        }
        */
    }
    
    func receiveMessagePressed(_ sender: UIBarButtonItem) {
        /**
         *  DEMO ONLY
         *
         *  The following is simply to simulate received messages for the demo.
         *  Do not actually do this.
         */
        
        /**
         *  Show the typing indicator to be shown
         */
        self.showTypingIndicator = !self.showTypingIndicator
        
        /**
         *  Scroll to actually view the indicator
         */
        self.scrollToBottom(animated: true)
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new JSQMessageData object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        //self.messages.append(Message())
        self.finishReceivingMessage()
        
}
    
    // MARK: JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        store.sendMessageWithText(text) { (success, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                return
            }
        }
        //self.messages.append(message)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
    }
    
    //MARK: JSQMessages CollectionView DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessage()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].id == self.senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if message.id == self.senderId {
            let initials = String(describing: store.currentUser()!.firstName.characters.first) + String(describing: store.currentUser()!.lastName.characters.first)
            return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: UIColor.gray, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: 20)
        } else {
            let initials = String(describing: chat.user.firstName.characters.first) + String(describing: chat.user.lastName.characters.first)
            return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: UIColor.blue, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), diameter: 20)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.createdAt as Date!)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        return 0.0
    }
    
    func getAvatar(_ message: JSQMessage) {
        
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
