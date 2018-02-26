//
//  ChatsPreviewController.swift
//  AllHBCU Messenger
//
//  Created by Travis Kellum on 2/25/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//

import UIKit

class ChatsPreviewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    var chats: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 30
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
