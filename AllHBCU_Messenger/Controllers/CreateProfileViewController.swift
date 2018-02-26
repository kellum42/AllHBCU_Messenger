//
//  CreateProfileViewController.swift
//  AllHBCU Messenger
//
//  Created by Travis Kellum on 2/24/18.
//  Copyright © 2018 KellumWebDev. All rights reserved.
//

import UIKit
import Firebase

class CreateProfileViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var error: UILabel!
    
    let db = Firestore.firestore()
    let colors: [UIColor] = [.red, .blue, .cyan, .purple, .yellow, .orange, .green]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textfield.delegate = self
        hideErrorMessage()
    }
}

extension CreateProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let text = textfield.text else { return true }
        if text == "" {
            showErrorWithMessage(message: "Enter a username")
            return true
        }
        
        hideErrorMessage()
    
        // Add a new document with a generated id.
        db.collection("profiles").document(text).setData([
            "name": text,
            "avatar_color": arc4random_uniform(UInt32(colors.count))
        ]){ [weak self] (err) in
            if let _  = err {
                self?.showErrorWithMessage(message: "An error occurred. Please try again later.")
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        return true
    }
}

extension CreateProfileViewController {
    func showErrorWithMessage(message: String){
        error.text = message
        error.alpha = 1
    }
    
    func hideErrorMessage(){
        error.alpha = 0
    }
}

