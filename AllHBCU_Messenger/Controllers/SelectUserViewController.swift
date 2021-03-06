//
//  SelectUserViewController.swift
//  AllHBCU Messenger
//
//  Created by Travis Kellum on 2/25/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//

import UIKit
import Firebase

class SelectUserViewController: UIViewController {

    let db = Firestore.firestore()
    var profiles: [User] = []
    var friendToMessage: User?
    var chatId: String?
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchProfiles()
        
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 30
    }

    func fetchProfiles(){
        
        db.collection("profiles").getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    guard let id = data["id"] as? String, let name = data["name"] as? String, let color = data["avatar_color"] as? Int else {
                        continue
                    }
                    
                    guard let me = AppVariables.shared.user else { return }
                    if me.id == id { continue }
                    
                    self?.profiles.append(User(id: id, name: name, avatarColor: color))
                }
                self?.tableview.reloadData()
            }
        }
    }
}

extension SelectUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (profiles.count == 0) ? 1 : profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
        if profiles.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell
            let user = profiles[indexPath.row]
            cell.selectionStyle = .default
            cell.configureCell(user: user)
            //cell.avatar.layer.cornerRadius = cell.avatar.frame.width / 2
            return cell
                
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if profiles.count > 0 {
            
            chatId = nil // reset chat id
            
            // check to see if conversation exists
            guard let user = AppVariables.shared.user else {
                // do some error handling
                return
            }
            
            let selectedUser = profiles[indexPath.row]
            friendToMessage = selectedUser
            
            db.collection("rooms")
                .whereField("users." + user.name.lowercased(), isEqualTo: true)
                .whereField("users." + selectedUser.name.lowercased(), isEqualTo: true)
            .getDocuments() { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("ERROR GETTING DOCUMENTS: \(err)")
                
                } else {
                    //  If there is a match, get the chatId
                    if querySnapshot!.documents.count > 0 {
                        let doc = querySnapshot!.documents[0]
                        if let lastMessage = doc.data()["last_message"] as? [String: Any], let chatId = lastMessage["chat_id"] as? String {
                            
                            self?.chatId = chatId
                        }
                    }
                    
                    // ensure the friend they're messaging and themselves exists
                    guard let _ = self?.friendToMessage, let _ = AppVariables.shared.user else {
                        // throw an error
                        return
                    }
                    
                    self?.performSegue(withIdentifier: "chooseUserToChat", sender: self)
                }
            }
        }
    }
}


extension SelectUserViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseUserToChat" {
            let destination = segue.destination as! ChatViewController
            destination.friend = friendToMessage!
            destination.me = AppVariables.shared.user!
            destination.chatId = chatId
        }
    }
}
