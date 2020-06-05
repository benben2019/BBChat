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
import AVFoundation

class ChatViewController: UICollectionViewController {

    var user: User!
    var messages = [ChatMessage]()
    
    lazy var inputBar: InputBar = {
        let bar = InputBar()
        bar.placeholder = "说点好听的吧..."
        bar.imagePickerClosoure = {[weak self] in
            self?.pickImage()
        }
        
        bar.sendButtonClosoure = {[weak self] in
            self?.sendMessage()
        }
        
        bar.barWillMoveUpCallback = {[weak self] (keyboardHeight,duration) in
            self?.inputTextViewBottomConstraint?.constant = -keyboardHeight
            self?.collectionViewTopConstraint?.constant = -keyboardHeight
            UIView.animate(withDuration: duration) {
                self?.view.layoutIfNeeded()
            }
            self?.scrollToBottom(true)
        }
        
        bar.barWillMoveDownCallback = {[weak self] (duration) in
            self?.inputTextViewBottomConstraint?.constant = 0
            self?.collectionViewTopConstraint?.constant = 0
            UIView.animate(withDuration: duration) {
                self?.view.layoutIfNeeded()
            }
        }
        
        return bar
    }()
    var inputTextViewBottomConstraint: NSLayoutConstraint?
    var collectionViewTopConstraint: NSLayoutConstraint?
    
    var imageUrl: String?
    var videoUrl: String?
    var coverImageUrl: String?
    var imageSize: CGSize?
    var originFrame: CGRect?
    var previewBgView: UIView?
    var originImageView: UIImageView?
    
    var scrollToBottomAnimated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        self.title = user.username
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: "cellId")
        
        setupInputView()
        setupColletcionView()
        fetchMessages()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func setupInputView() {
        view.addSubview(inputBar)
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        inputTextViewBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputTextViewBottomConstraint?.isActive = true
    }
    
    func setupColletcionView() {
        
        // iphoneX机型上，collectionView默认已经拥有top：88 和 bottom：34 的inset，所以自己设置的inset都是基于这个原有的inset基础上
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        collectionViewTopConstraint?.isActive = true
        collectionView.bottomAnchor.constraint(equalTo: inputBar.topAnchor).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        collectionView.addGestureRecognizer(tap)
    }
    
    
//    override var inputAccessoryView: UIView? {
//        return inputTextView
//    }
//
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    @objc private func handleTap() {
        inputBar.textViewResignFirstResponder()
    }
    
    func fetchMessages() {
        print("即将要查询与\(user.uid)用户的聊天记录")
        FirebaseManager.shared.queryChatMessages(user.uid) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                self.messages = messages
                self.collectionView.reloadData()
                self.scrollToBottom(self.scrollToBottomAnimated)
                self.scrollToBottomAnimated = true
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
        let inputText = imageUrl != nil ? "[图片]" : (videoUrl != nil ? "[视频]" : inputBar.inputText ?? "")
        let imageUrl = self.imageUrl ?? ""
        let videoUrl = self.videoUrl ?? ""
        let coverImageUrl = self.coverImageUrl ?? ""
        let timestamp = Date().timeIntervalSince1970
        let fromUid = FirebaseManager.shared.currentUser!.uid
        let toUid = user.uid
        print("\(inputText) -- \(timestamp) -- from: \(fromUid) -- to: \(toUid)")
        
        if inputText.count == 0 && imageUrl.count == 0 && videoUrl.count == 0 { return }
        
        let data: [String : Any] = ["content": inputText, "imageUrl": imageUrl,"videoUrl": videoUrl,"coverImageUrl": coverImageUrl,"imageWidth": imageSize?.width ?? 0,"imageHeight": imageSize?.height ?? 0,"timestamp": timestamp, "fromUid": fromUid, "toUid": toUid]
        let ref = FirebaseManager.shared.updateMessages(data)  // 将本条消息存入数据库
        
        let value = [ref.documentID : 1]
        FirebaseManager.shared.updateUserMessages(value,documentId: fromUid,subDocumentId: toUid) // 以发送方id为索引存入一份 本条消息的索引
        
        FirebaseManager.shared.updateUserMessages(value, documentId: toUid,subDocumentId: fromUid)  // 以接收方id为索引存入一份 本条消息的索引
        
        inputBar.inputText = nil
        self.imageUrl = nil
        self.coverImageUrl = nil
        self.videoUrl = nil
    }
    
    @objc func pickImage() {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.mediaTypes = [kUTTypeImage as String,kUTTypeMPEG4 as String]
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @objc func dismissPreviewImage(_ tap: UITapGestureRecognizer) {
        if let imageView = tap.view {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                imageView.frame = self.originFrame!
                self.previewBgView!.alpha = 0
                self.inputBar.alpha = 1.0
                imageView.layer.cornerRadius = self.originImageView!.layer.cornerRadius
                imageView.clipsToBounds = true
            }) { (_) in
                imageView.removeFromSuperview()
                self.originImageView?.isHidden = false
            }
        }
        
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
                self.inputBar.textViewResignFirstResponder()
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
                    self.inputBar.alpha = 0
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
            uploadImage(editImage) {[weak self] (_) in
                self?.sendMessage()
            }
        } else if let oriImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageSize = oriImage.size
            uploadImage(oriImage) {[weak self] (_) in
                self?.sendMessage()
            }
        } else if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL { // video
            
            let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: videoUrl))
            imageGenerator.appliesPreferredTrackTransform = true // 修正图片的方向
            var coverImage: UIImage?
            do {
                let cgImage = try imageGenerator.copyCGImage(at: .init(value: 1, timescale: 60), actualTime: nil)
                coverImage = UIImage(cgImage: cgImage)
                self.imageSize = coverImage?.size
            } catch {
                print(error.localizedDescription)
            }
            
            guard let videoCoverImage = coverImage else { return }
            // 先上传视频封面
            uploadImage(videoCoverImage) {[weak self] (coverImageUrl) in
                self?.coverImageUrl = coverImageUrl
                // 解决iOS13下由于videoUrl路径改变引起的上传失败的问题
                // 具体可参考:https://stackoverflow.com/questions/58104572/cant-upload-video-to-firebase-storage-on-ios-13
                if #available(iOS 13, *) {
                    //If on iOS13 slice the URL to get the name of the file
                    let urlString = videoUrl.relativeString
                    let urlSlices = urlString.split(separator: ".")
                    //Create a temp directory using the file name
                    let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                    let targetURL = tempDirectoryURL.appendingPathComponent(String(urlSlices[1])).appendingPathExtension(String(urlSlices[2]))
                    
                    //Copy the video over
                    do {
                        try FileManager.default.copyItem(at: videoUrl, to: targetURL)
                        self?.uploadVideo(targetURL)
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    self?.uploadVideo(videoUrl)
                }
            }
            
        }
    }
}

extension ChatViewController {
    
    fileprivate func uploadVideo(_ videoUrl: URL) {
        self.imageUrl = nil
        let videoName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("videos/chat/" + "\(videoName).mov")
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
        
        let uploadTask = storageRef.putFile(from: videoUrl, metadata: nil) {[weak self] (metadata, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.dismiss(animated: true, completion: nil)
                return
            } else {
                print("视频上传成功！")
                print(metadata!.path as Any)
                print(metadata!.contentType as Any)
                print(metadata!.size)
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  // Uh-oh, an error occurred!
                  return
                }
                
                print(downloadURL.absoluteString)
                self.videoUrl = downloadURL.absoluteString
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
    
    fileprivate func uploadImage(_ image: UIImage, completion: ((String) -> Void)? = nil) {
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
                
                if let callback = completion {
                    callback(downloadURL.absoluteString)
                }
                
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
