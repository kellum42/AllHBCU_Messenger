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
    let participants: [String: Bool]
    let lastMessage: [String: String]
}

class ChatsPreviewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    let db = Firestore.firestore()
    var chats: [ChatPreviews] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchChats()
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 30
    }
    
    func fetchChats(){
        guard let user = AppVariables.shared.user else { return }
        db.collection("rooms")
            .whereField("users." + user.name.lowercased(), isEqualTo: true)
            .getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                // error handling
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print(document.data())
                }
                // self?.tableview.reloadData()
            }
        }
    }
}

extension ChatsPreviewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (chats.count > 0) ? chats.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chats.count > 0 {
            return UITableViewCell()
        
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newChatCell")
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        if chats.count > 0 {
            
            
        } else {
            // create new chat
            performSegue(withIdentifier: "toChooseUser", sender: self)
        }
    }
}
