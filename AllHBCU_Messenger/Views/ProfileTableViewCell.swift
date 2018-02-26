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

    func configureCell(profile: [String: Any]){
        let colors: [UIColor] = [.red, .blue, .cyan, .purple, .yellow, .orange, .green]
        
        name.text = nil
        avatar.text = nil
        avatar.backgroundColor = nil
        avatar.layer.cornerRadius = avatar.frame.width / 2
        
        guard let name = profile["name"] as? String, let color = profile["avatar_color"] as? Int else {
            return
        }
        self.name.text = name
        self.avatar.text = String(describing: name.first!).uppercased()
        self.avatar.backgroundColor = colors[color]
    }
}
