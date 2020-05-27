//
//  ChatViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/27.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

class ChatViewController: UICollectionViewController {

    var user: User!
    
    lazy var inputTextfield: UITextField = {
        let textfield = UITextField()
        textfield.textColor = .darkGray
        textfield.placeholder = "说点什么吧..."
        textfield.tintColor = .black
        textfield.delegate = self
        return textfield
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.backgroundColor = .white
        
        self.title = user.username
        
        let inputView = UIView()
        inputView.backgroundColor = UIColor(r: 227, g: 230, b: 225)
        inputView.hstack(UIView().withWidth(10),inputTextfield,sendButton.withWidth(50))
        
        view.stack(UIView(),inputView.withHeight(50),UIView().withHeight(kBottomSafeHeight))
    }
    
    @objc func sendMessage() {
        let inputText = inputTextfield.text ?? ""
        let timestamp = Date().timeIntervalSince1970
        let fromUid = FirebaseManager.shared.currentUser!.uid
        let toUid = user.uid!
        print("\(inputText) -- \(timestamp) -- from: \(fromUid) -- to: \(toUid)")
        
        let data: [String : Any] = ["content": inputText, "timestamp": timestamp, "fromUid": fromUid, "toUid": toUid]
        let ref = FirebaseManager.shared.updateMessages(data)
        
        let value = [ref.documentID : 1]
        FirebaseManager.shared.updateUserMessages(value,documentId: fromUid)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
