//
//  FirebaseManager.swift
//  BBChat
//
//  Created by Ben on 2020/5/27.
//  Copyright © 2020 Benben. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseManager {
    static let shared = FirebaseManager()
    
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func updateUser(_ values: [String : Any]) {
        Firestore.firestore().collection("users").addDocument(data: values) { (err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("用户 \(values) 已存入数据库！")
            }
        }
    }
    
    func updateUser(uid: String,username: String,iconUrl: String?) {
        updateUser(["uid": uid, "username": username, "iconUrl": iconUrl ?? ""])
    }
    
    func updateMessages(_ values: [String : Any]) -> DocumentReference {
        return Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("消息 \(values) 已存入数据库！")
            }
        }
        
    }
    
    func updateUserMessages(_ values: [String : Any],documentId: String) {
        // 在user_messages 目录下创建 documentId 目录，如果还没有documentId的目录则创建新的，如果有了则将新的values写进documentId目录下（合并模式，documentId目录下旧的东西保留）
        Firestore.firestore().collection("user_messages").document(documentId).setData(values, merge: true) { (err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("消息索引 \(values) 已存入数据库！")
            }
        }
    }
    
    func fetchUserList(completion: @escaping (Result<[User],Error>) -> Void) {
        Firestore.firestore().collection("users").addSnapshotListener { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(.failure(error!))
                return
            }
            
            let username = documents.map { $0["username"]! }
            print("Current users : \(username)")
            
            var users = [User]()
            let _ = documents.map { (document) in
                let user = User()
                user.uid = document.data()["uid"] as? String
                user.username = document.data()["username"] as? String
                user.iconUrl = document.data()["iconUrl"] as? String
                users.append(user)
            }
            completion(.success(users))
        }
    }
    
    func fetchChatList(completion: @escaping (Result<[ChatMessage],Error>) -> Void) {
        var messages = [ChatMessage]()
        var messageDic = [String : ChatMessage]()
        let currentUid = Auth.auth().currentUser!.uid
        Firestore.firestore().collection(BBUserMessageKey).document(currentUid).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let messageIds = snapshot?.data()?.keys {
                messageIds.forEach { (messageId) in
                    Firestore.firestore().collection(BBMessageKey).document(messageId).getDocument { (document, err) in
                        if let err = err {
                            completion(.failure(err))
                        }
                        let message = ChatMessage()
                        message.content = document!["content"] as? String
                        message.fromUid = document!["fromUid"] as? String
                        message.toUid = document!["toUid"] as? String
                        message.timestamp = document!["timestamp"] as? TimeInterval
                        print(document!["timestamp"] as? TimeInterval as Any)
                        // 同一个人的消息只保留了最新的一条
                        messageDic[message.toUid!] = message
                        
                    }
                }
                // 保证刚刚发的信息排在最前面（倒序排列）
                messages = Array(messageDic.values).sorted(by: {$0.timestamp! > $1.timestamp!})
                completion(.success(messages))
            }
            
        }
        
        // 这里将查询出来的结果按时间戳正序排列
//        Firestore.firestore().collection("messages").order(by: "timestamp").addSnapshotListener { (snapshot, error) in
//            guard let documents = snapshot?.documents else {
//                print("Error fetching documents: \(error!)")
//                completion(.failure(error!))
//                return
//            }
//
//            let toUidList = documents.map { $0["toUid"]! }
//            print("Current chat messages : \(toUidList)")
//
//            var messages = [ChatMessage]()
//            var messageDic = [String : ChatMessage]()
//            documents.forEach { (document) in
//                let message = ChatMessage()
//                message.content = document["content"] as? String
//                message.fromUid = document["fromUid"] as? String
//                message.toUid = document["toUid"] as? String
//                message.timestamp = document["timestamp"] as? TimeInterval
//                print(document["timestamp"] as? TimeInterval as Any)
//                // 同一个人的消息只保留了最新的一条
//                messageDic[message.toUid!] = message
//            }
//
//            // 保证刚刚发的信息排在最前面（倒序排列）
//            messages = Array(messageDic.values).sorted(by: {$0.timestamp! > $1.timestamp!})
//            completion(.success(messages))
//        }
    }
}
