//
//  ProfileTableViewCell.swift
//  AllHBCU Messenger
//
//  Created by Travis Kellum on 2/24/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UILabel!
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(user: User){
        let colors: [UIColor] = [.red, .blue, .cyan, .purple, .yellow, .orange, .green]
        
        name.text = nil
        avatar.text = nil
        avatar.backgroundColor = nil
        avatar.layer.cornerRadius = avatar.frame.width / 2
        
      
        self.name.text = user.name
        self.avatar.text = String(describing: user.name.first!).uppercased()
        self.avatar.backgroundColor = colors[user.avatarColor]
    }
}
