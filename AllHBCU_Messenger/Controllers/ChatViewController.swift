//
//  ChatViewController.swift
//  AllHBCU Messenger
//
//  Created by Travis Kellum on 2/27/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//

//  When first message is sent create room
//  If message id is 1, create chat room
//  On each message sent create message doc with chat id in it

import UIKit
import Firebase
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    var friend: User!
    var me: User!
    
    var originalMessages: [[String: Any]] = []
    var messages = [JSQMessage]()
    
    lazy var outgoingBubbleImageView = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        senderDisplayName = me.name.capitalized
        senderId = String(me.id)
        
        title = friend.name.capitalized
        
        //  remove avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generateFakeMessages()
    }
    
    
    // for testing
    func generateFakeMessages(){
        func addTestMessage(withId id: String, name: String, text: String) {
            if let message = JSQMessage(senderId: id, displayName: name, text: text) {
                messages.append(message)
            }
        }
        
        addTestMessage(withId: String(friend.id), name: friend.name, text: "Will it work?")
        addTestMessage(withId: senderId, name: me.name, text: "I think it will")
        addTestMessage(withId: senderId, name: me.name, text: "I think i was right")
        
        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
}


extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        cell.textView?.textColor = UIColor.white
        
        if message.senderId != senderId {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }
        return incomingBubbleImageView
    }
    
    //  send no data for avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
