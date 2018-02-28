//
//  ChatPreviewTableViewCell.swift
//  AllHBCU Messenger
//
//  Created by Travis on 2/28/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//

import UIKit

class ChatPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UILabel!
    @IBOutlet weak var participants: UILabel!
    @IBOutlet weak var previewText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print("WAS INITIALIZED")
    }

    func configureCell(chat: ChatPreviews){
        let colors: [UIColor] = [.red, .blue, .cyan, .purple, .yellow, .orange, .green]
        
        self.avatar.text = String(chat.participants[0].name.uppercased().first!)
        self.avatar.backgroundColor = colors[chat.participants[0].avatarColor]
        self.avatar.layer.cornerRadius = avatar.layer.frame.width / 2
        
        var text = ""
        text = (chat.senderId == AppVariables.shared.user!.id) ? "You: " : ""
        text += chat.messageText
        previewText.text = text
        previewText.textColor = UIColor.gray
        
        participants.text = chat.participants[0].name.capitalized
    }

}
