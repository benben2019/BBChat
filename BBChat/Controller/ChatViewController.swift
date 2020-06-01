//
//  ChatViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/27.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

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
    
    let mediaPickButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.addTarget(self, action: #selector(mediaPick), for: .touchUpInside)
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = UIColor.systemBlue.cgColor
        btn.layer.borderWidth = 1
        btn.titleLabel?.font = .systemFont(ofSize: 20)
        return btn
    }()
    
    lazy var inputTextView: UIView = {
        let inputTextView = UIView(frame: .init(x: 0, y: 0, width: self.view.frame.size.width, height: 50 + kBottomSafeHeight))
        inputTextView.backgroundColor = .white
        let line = UIView().withHeight(1)
        line.backgroundColor = UIColor(r: 227, g: 230, b: 225)
        inputTextView.stack(line,
                            UIView().hstack(UIView().withWidth(5),
                                            mediaPickButton.withSize(.init(width: 30, height: 30)),
                                            inputTextfield,
                                            sendButton.withWidth(50),
                                            spacing: 5,
                                            alignment: .center),
                            UIView().withHeight(kBottomSafeHeight))
        
//        view.addSubview(inputTextView)
//        inputTextView.translatesAutoresizingMaskIntoConstraints = false
//        inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        inputTextView.heightAnchor.constraint(equalToConstant: 50 + kBottomSafeHeight).isActive = true
//        inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        inputTextViewBottomConstraint?.isActive = true
        return inputTextView
    }()
    
    var inputTextViewBottomConstraint: NSLayoutConstraint?
    
    var imageUrl: String?
    var videoUrl: String?
    var imageSize: CGSize?
    var originFrame: CGRect?
    var previewBgView: UIView?
    var originImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        self.title = user.username
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: "cellId")
        
        setupColletcionView()
//        addKeyboardObservers()
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
    
    func setupColletcionView() {
        
        // iphoneX机型上，collectionView默认已经拥有top：88 和 bottom：34 的inset，所以自己设置的inset都是基于这个原有的inset基础上
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
    
    override var inputAccessoryView: UIView? {
        return inputTextView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
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
                self.scrollToBottom(true)
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
        let inputText = imageUrl != nil ? "[图片]" : (videoUrl != nil ? "[视频]" : inputTextfield.text!)
        let imageUrl = self.imageUrl ?? ""
        let videoUrl = self.videoUrl ?? ""
        let timestamp = Date().timeIntervalSince1970
        let fromUid = FirebaseManager.shared.currentUser!.uid
        let toUid = user.uid
        print("\(inputText) -- \(timestamp) -- from: \(fromUid) -- to: \(toUid)")
        
        if inputText.count == 0 && imageUrl.count == 0 && videoUrl.count == 0 { return }
        
        let data: [String : Any] = ["content": inputText, "imageUrl": imageUrl,"videoUrl": videoUrl,"imageWidth": imageSize?.width ?? 0,"imageHeight": imageSize?.height ?? 0,"timestamp": timestamp, "fromUid": fromUid, "toUid": toUid]
        let ref = FirebaseManager.shared.updateMessages(data)  // 将本条消息存入数据库
        
        let value = [ref.documentID : 1]
        FirebaseManager.shared.updateUserMessages(value,documentId: fromUid,subDocumentId: toUid) // 以发送方id为索引存入一份 本条消息的索引
        
        FirebaseManager.shared.updateUserMessages(value, documentId: toUid,subDocumentId: fromUid)  // 以接收方id为索引存入一份 本条消息的索引
        
        inputTextfield.text = nil
    }
    
    @objc func mediaPick() {
        let pickerVc = UIImagePickerController()
        pickerVc.allowsEditing = true
        pickerVc.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String] // 需要import MobileCoreServices
        pickerVc.delegate = self
        present(pickerVc, animated: true, completion: nil)
    }
    
    @objc func dismissPreviewImage(_ tap: UITapGestureRecognizer) {
        if let imageView = tap.view {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                imageView.frame = self.originFrame!
                self.previewBgView!.alpha = 0
                self.inputTextView.alpha = 1.0
                imageView.layer.cornerRadius = self.originImageView!.layer.cornerRadius
                imageView.clipsToBounds = true
            }) { (_) in
                imageView.removeFromSuperview()
                self.originImageView?.isHidden = false
            }
        }
        
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
        cell.previewImageClosoure = {[weak self] (originFrame,oriImageView) in
            guard let self = self else { return }
            self.originFrame = originFrame
            self.originImageView = oriImageView
            
            if let keywindow = UIApplication.shared.keyWindow {
                self.inputTextfield.resignFirstResponder()
                let bgView = UIView(frame: keywindow.bounds)
                bgView.backgroundColor = .black
                bgView.alpha = 0
                keywindow.addSubview(bgView)
                self.previewBgView = bgView
                
                let imageView = UIImageView(frame: originFrame)
                imageView.image = oriImageView.image
                imageView.isUserInteractionEnabled = true
                keywindow.addSubview(imageView)
                
                oriImageView.isHidden = true
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    imageView.frame = CGRect(x: 0, y: 0, width: keywindow.bounds.size.width, height: keywindow.bounds.size.width * originFrame.size.height / originFrame.size.width)
                    imageView.center = keywindow.center
                    bgView.alpha = 1.0
                    self.inputTextView.alpha = 0
                }, completion: nil)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPreviewImage))
                imageView.addGestureRecognizer(tap)
                
            }
        }
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.item]
        print(message.content)
        if message.type == .text {
            let content = message.content
            var height = ceil(content.textSize(.maxChatTextWidth, attributes: chatTextAttibutes).height) + UIEdgeInsets.chatBubbleInsets.top + UIEdgeInsets.chatBubbleInsets.bottom
            height = height < CGFloat.minBubbleHeight ? CGFloat.minBubbleHeight : height
            return .init(width: view.bounds.size.width, height: height)
        } else {
            return .init(width: view.bounds.size.width, height: CGFloat.maxChatTextWidth * message.imageHeight / message.imageWidth)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
}

extension ChatViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageSize = editImage.size
            uploadImage(editImage)
        } else if let oriImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageSize = oriImage.size
            uploadImage(oriImage)
        }
    }
}

extension ChatViewController {
    fileprivate func uploadImage(_ image: UIImage) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("images/chat/" + "\(imageName).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let uploadTask = storageRef.putData(imageData, metadata: metadata) {[weak self] (metadata, error) in
            
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
                return
            } else {
                print("图片上传成功！")
                print(metadata!.path as Any)
                print(metadata!.contentType as Any)
                print(metadata!.size)
            }
            
            // 获取图片地址
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
                
                print(downloadURL.absoluteString)
                self.imageUrl = downloadURL.absoluteString
                
                self.sendMessage()
                
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        // 上传进度
        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            
            print("上传进度：\(String(format: "%.2f", percentComplete))%")
        }
    }
}
