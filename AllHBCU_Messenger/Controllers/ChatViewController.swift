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

//  TODO: Pass the number of messags to this controller so the last X
//  messages can be filtered and more can be fetched as the user desires

import UIKit
import Firebase
import JSQMessagesViewController

struct Message {
    let chatId: String?
    let text: String
    let senderName: String
    let senderId: String
    let messageNumber: Int
}

class ChatViewController: JSQMessagesViewController {
    let db = Firestore.firestore()
    
    var friend: User!
    var me: User!
    var chatId: String?
    
    var originalMessages: [[String: Any]] = []
    var messages = [JSQMessage]()
    var listenerQueries: Int = 0
    
    lazy var outgoingBubbleImageView = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //  start loading in messages
        loadSavedMessages()
        
        senderDisplayName = me.name.capitalized
        senderId = String(me.id)
        
        title = friend.name.capitalized
        
        //  remove avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        listenForNewMessages()
    }

  
    func loadSavedMessages(){
        guard let chatId = chatId else {
            return
        }
        

        db.collection("messages").whereField("chat_id", isEqualTo: chatId)
            .order(by: "messageNumber")
            .getDocuments() { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("ERROR GETTING DOCUMENTS: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        guard let jQSMessage = self?.jsonToJQSMessage(json: document.data()) else {
                            continue
                        }
                        self?.messages.append(jQSMessage)
                    }
                    self?.finishSendingMessage(animated: false)
                }
        }
    }
    
    //  Listens for any updates to the last_message field in the rooms document
    //  When updates occur, pushes message into the UI
    //  TODO: Add in messages with images/videos
    func listenForNewMessages(){
        guard let chatId = chatId else {
            return
        }
        
        let room = String(chatId.dropLast(5))
        
        db.collection("rooms").document(room)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                
                //  skip the initial snapshot because the message will be included
                //  in the call for all the messages
                self?.listenerQueries += 1
                if self?.listenerQueries == 1 { return }
                
                guard let document = documentSnapshot else {
                    print("ERROR LISTENING TO DOCUMENT: \(error!)")
                    return
                }
                
                
                guard let data = document.data(), let lastMessage = data["last_message"] as? [String: Any], let newMessage = self?.jsonToJQSMessage(json: lastMessage) else {
                    return
                }
                
                self?.messages.append(newMessage)
                self?.finishSendingMessage()
        }
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text == "" { return }
       
        let message = Message(chatId: chatId, text: text, senderName: senderDisplayName.lowercased(), senderId: senderId, messageNumber: messages.count + 1)
        
        onMessageSend(message: message)
    }
    
    func jsonToJQSMessage(json: [String: Any]) -> JSQMessage? {
        guard let senderId = json["sender_id"] as? String, let senderName = json["sender_name"] as? String, let text = json["text"] as? String else {
            return nil
        }
        
        return JSQMessage(senderId: senderId, displayName: senderName, text: text)
    }
}



extension ChatViewController {
    
    //  Adds the new message into the firestore database.
    //  If there is only one message, creates a chat room in the db.
    //  Publishes message into the db in the messages collection.
    //  Each message added is a new document in the db.
    func onMessageSend(message: Message){
        
        //  If this is the first message, create the chat room doc.
        // Then store the message as normal.
        if message.messageNumber == 1 {
            //  create room
            var messageRef: DocumentReference?
            messageRef = db.collection("rooms").addDocument(data: [
                "users": [
                    me.name.lowercased(): true,
                    friend.name.lowercased(): true
                ],
                "user_data": [
                    [
                        "id": me.id,
                        "name": me.name,
                        "color": me.avatarColor
                    ],
                    [
                        "id": friend.id,
                        "name": friend.name,
                        "color": friend.avatarColor
                    ]
                ]
            ]) { [weak self] err in
                if let err = err {
                    print("Error adding room document: \(err)")
                } else {
                    print("Document added with ID: \(messageRef!.documentID)")
                    
                    if self?.chatId == nil {
                        self?.chatId = messageRef!.documentID + "_full"
                        
                        //  start listening for new messages
                        self?.listenForNewMessages()
                        self?.publishMessage(message: message)
                    }
                }
            }
            
        } else {
            publishMessage(message: message)
        }
    }
    
    
    //  Stores message into the db
    //  Also updates last_message in the chat room doc
    func publishMessage(message: Message){
        
        //  Each message needs a chat id so all messages within the same
        //  chat can be queried easily
        guard let chatId = chatId else {
            //  error handling here
            print("NO CHAT ID")
            return
        }
        
        //  store message in db
        db.collection("messages").addDocument(data: [
            "chat_id": chatId,
            "sender_name": message.senderName,
            "sender_id": message.senderId,
            "text": message.text,
            "messageNumber": message.messageNumber,
            "timestamp": Date().timeIntervalSince1970
            
        ]) { [weak self] err in
            if let err = err {
                print("ERROR ADDING DOCUMENT: \(err)")
            } else {
                print("MESSAGE DOCUMENT CREATED")
                
                // log to last_message field in chat room doc
                
                //  Get the document name for the chat room doc
                //  CHAT_ID = ROOM_ID + _full
                let room = String(chatId.dropLast(5))
                
                self?.db.collection("rooms").document(room).setData(
                    [
                        "last_message": [
                            "chat_id": chatId,
                            "sender_name": message.senderName,
                            "sender_id": message.senderId,
                            "text": message.text,
                            "messageNumber": message.messageNumber,
                            "timestamp": Date().timeIntervalSince1970
                        ],
                        ],
                    options: SetOptions.merge()
                    
                ) { err in
                    if let err = err {
                        print("ERROR WRITING DOCUMENT: \(err)")
                    } else {
                        print("LAST MESSAGE SUCCESSFULLY UPDATED!")
                    }
                }
            }
        }
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
