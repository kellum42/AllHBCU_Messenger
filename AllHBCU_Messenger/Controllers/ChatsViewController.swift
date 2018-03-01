//
//  ChatsPreviewController.swift
//  AllHBCU Messenger
//
//  Created by Travis Kellum on 2/25/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//

import UIKit
import Firebase

struct ChatPreviews {
    let chatId: String
    let participants: [User]
    let senderId: String
    let messageText: String
}

class ChatsPreviewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    let db = Firestore.firestore()
    var chats: [ChatPreviews] = []
    var selectedChat: ChatPreviews?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = AppVariables.shared.user else {
            //  error handling - kill view controller
            // user doesn't exist
            return
        }
        
        fetchChats()
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 30
    }
}


extension ChatsPreviewController {

    func fetchChats(){
        guard let user = AppVariables.shared.user else { return }
        db.collection("rooms")
            .whereField("users." + user.name.lowercased(), isEqualTo: true)
            .getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                // error handling
                print("ERROR GETTING DOCUMENTS: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let users = data["user_data"] as? [[String: Any]], let lastMessage = data["last_message"] as? [String: Any], let senderId = lastMessage["sender_id"] as? String, let chatId = lastMessage["chat_id"] as? String, let text = lastMessage["text"] as? String else {
                        //  error handling
                        print("ERROR PARSING ROOM")
                        return
                    }
                    
                    var userArray: [User] = []
                    for user in users {
                        if let id = user["id"] as? String, let color = user["color"] as? Int, let name = user["name"] as? String {
                            //  skip the current user
                            if id == AppVariables.shared.user!.id { continue }
                            userArray.append(User(id: id, name: name, avatarColor: color))
                        }
                    }
                    
                    if userArray.count == 0 {
                        //  error handling here
                        print("USER PARSING ISSUE")
                        return
                    }
                    self?.chats.append(ChatPreviews(chatId: chatId, participants: userArray, senderId: senderId, messageText: text))
                }
                self?.tableview.reloadData()
            }
        }
    }
}

extension ChatsPreviewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatPreview", for: indexPath) as! ChatPreviewTableViewCell
        cell.configureCell(chat: chats[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
 
        selectedChat = chats[indexPath.row]
        performSegue(withIdentifier: "chatsPreviewToChat", sender: self)
    }
}


extension ChatsPreviewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatsPreviewToChat" {
            let destination = segue.destination as! ChatViewController
            destination.chatId = selectedChat?.chatId
            destination.friend = selectedChat!.participants[0]
            destination.me = AppVariables.shared.user!
        }
    }
}
