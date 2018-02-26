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
    var profiles: [[String: Any]] = []
    
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
                    self?.profiles.append(document.data())
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
            let profile = profiles[indexPath.row]
            cell.selectionStyle = .default
            cell.configureCell(profile: profile)
            //cell.avatar.layer.cornerRadius = cell.avatar.frame.width / 2
            return cell
                
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if profiles.count > 0 {
            // create new chat preview
            // create new chat
            // pop controller
            /*
            ref = db.collection("chat_previews").addDocument(data: [
                "participants": [],
                "chat_id": "Turing",
                "born": 1912
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            */
        }
    }
}

