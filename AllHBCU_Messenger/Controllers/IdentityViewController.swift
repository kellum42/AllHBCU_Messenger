//
//  ViewController.swift
//  AllHBCU Messenger
//
//  Created by Travis Kellum on 2/24/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//


//  Make the user choose a profile
//  Can either choose existing or create a new one
//  If no profiles exist, make user choose to make a new one

import UIKit
import Firebase

struct User {
    let id: Int
    let name: String
    let avatarColor: Int
}

class AppVariables {
    static let shared = AppVariables()
    private init(){}
    
    var user: User?
}

class IdentityViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var profiles: [User] = []
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProfiles()
        
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 30
    }
    
    func fetchProfiles(){
        //let colors: [UIColor] = [.red, .blue, .cyan, .purple, .yellow, .orange, .green]
        
        db.collection("profiles").getDocuments() { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                   let data = document.data()
                    guard let id = data["id"] as? Int, let name = data["name"] as? String, let color = data["avatar_color"] as? Int else {
                        return
                    }
                    
                    self?.profiles.append(User(id: id, name: name, avatarColor: color))
                }
                self?.tableview.reloadData()
            }
        }
    }
}

extension IdentityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (profiles.count == 0) ? 1 : profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
 
        if profiles.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell
            let profile = profiles[indexPath.row]
            cell.selectionStyle = .default
            cell.configureCell(user: profile)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createProfileCell") as! CreateProfileTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        AppVariables.shared.user = profiles[indexPath.row]
        // segue to new controller
        performSegue(withIdentifier: "toChats", sender: self)
    }
}
