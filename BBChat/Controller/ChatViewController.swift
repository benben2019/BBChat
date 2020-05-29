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
    
    var inputTextView = UIView()
    var inputTextViewBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        self.title = user.username
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: "cellId")
        
        setupInputView()
        addKeyboardObservers()
        fetchMessages()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ noti: Notification) {
        if let userInfo = noti.userInfo {
            let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            inputTextViewBottomConstraint?.constant = -height
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            }) { (_) in
                self.scrollToBottom(true)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ noti: Notification) {
        if let userInfo = noti.userInfo {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            inputTextViewBottomConstraint?.constant = 0
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setupInputView() {
        
        inputTextView.backgroundColor = .white
        let line = UIView().withHeight(1)
        line.backgroundColor = UIColor(r: 227, g: 230, b: 225)
        inputTextView.stack(line,UIView().hstack(UIView().withWidth(10),inputTextfield,sendButton.withWidth(50)),UIView().withHeight(kBottomSafeHeight))
        
        view.addSubview(inputTextView)
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        inputTextView.heightAnchor.constraint(equalToConstant: 50 + kBottomSafeHeight).isActive = true
        inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputTextViewBottomConstraint?.isActive = true
        
        // iphoneX机型上，collectionView默认已经拥有top：88 和 bottom：34 的inset，所以自己设置的inset都是基于这个原有的inset基础上
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 50 + 8, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 50 + 8, right: 0)
        collectionView.alwaysBounceVertical = true
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
                self.scrollToBottom()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func scrollToBottom(_ animated: Bool = false) {
        if self.messages.count > 0 {
            self.collectionView.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: animated)
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
        cell.message = message
        cell.iconUrl = user.iconUrl
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let content = messages[indexPath.item].content!
        var height = ceil(content.textSize(.maxChatTextWidth, attributes: chatTextAttibutes).height) + UIEdgeInsets.chatBubbleInsets.top + UIEdgeInsets.chatBubbleInsets.bottom
        height = height < CGFloat.minBubbleHeight ? CGFloat.minBubbleHeight : height
        return .init(width: view.bounds.size.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
}
