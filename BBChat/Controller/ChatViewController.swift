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
    var messages = [ChatMessage]()
    
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
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        self.title = user.username
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: "cellId")
        
        setupInputView()
        fetchMessages()
    }
    
    func setupInputView() {
        
        let inputView = UIView()
        let line = UIView().withHeight(1)
        line.backgroundColor = UIColor(r: 227, g: 230, b: 225)
        inputView.stack(line,UIView().hstack(UIView().withWidth(10),inputTextfield,sendButton.withWidth(50)))
        
        view.addSubview(inputView)
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        inputView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        inputView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        inputView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -kBottomSafeHeight).isActive = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: inputView.topAnchor,constant: -5).isActive = true
    }
    
    func fetchMessages() {
        print("即将要查询与\(user.uid)用户的聊天记录")
        FirebaseManager.shared.queryChatMessages(user.uid) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
//                print(messages)
                self.messages = messages
                self.collectionView.reloadData()
                if self.messages.count > 0 {
                    self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func sendMessage() {
        let inputText = inputTextfield.text ?? ""
        let timestamp = Date().timeIntervalSince1970
        let fromUid = FirebaseManager.shared.currentUser!.uid
        let toUid = user.uid
        print("\(inputText) -- \(timestamp) -- from: \(fromUid) -- to: \(toUid)")
        
        let data: [String : Any] = ["content": inputText, "timestamp": timestamp, "fromUid": fromUid, "toUid": toUid]
        let ref = FirebaseManager.shared.updateMessages(data)  // 将本条消息存入数据库
        
        let value = [ref.documentID : 1]
        FirebaseManager.shared.updateUserMessages(value,documentId: fromUid) // 以发送方id为索引存入一份 本条消息的索引
        
        FirebaseManager.shared.updateUserMessages(value, documentId: toUid)  // 以接收方id为索引存入一份 本条消息的索引
        
        inputTextfield.text = nil
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatCell
        let message = messages[indexPath.item]
        cell.textLab.text = message.content
        cell.timeLab.text = message.timestamp.converToDateString(.longDate)
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.bounds.size.width, height: 50)
    }
}
