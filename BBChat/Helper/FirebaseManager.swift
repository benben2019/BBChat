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
    
    func queryUser(_ uid: String, completion: @escaping ((User) -> Void)) {
        Firestore.firestore().collection(BBUserKey).whereField("uid", isEqualTo: uid).getDocuments {(documents, error) in
            if let documents = documents?.documents,let curUser = documents.first?.data() {
                let user = User.userWithValues(values: curUser)
                completion(user)
            }
        }
    }
    
    func queryChatMessages(_ uid: String, completion: @escaping (Result<[ChatMessage],Error>) -> Void) {
        Firestore.firestore().collection(BBUserMessageKey).document(uid).addSnapshotListener { (snapshot, error) in
            if let sn = snapshot, let messageIds = sn.data()?.keys {
                print(messageIds)
                self.queryMessages(messageIds, isAll: true, completion: completion)
            }
        }
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
            
//            let username = documents.map { $0["username"]! }
//            print("Current users : \(username)")
            
            let users = documents.map({User.userWithValues(values: $0.data())})
            completion(.success(users))
        }
    }
    
    func fetchChatList(completion: @escaping (Result<[ChatMessage],Error>) -> Void) {
        let currentUid = Auth.auth().currentUser!.uid
        Firestore.firestore().collection(BBUserMessageKey).document(currentUid).addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let messageIds = snapshot?.data()?.keys {
                self.queryMessages(messageIds, completion: completion)
            }
            
        }
    }
    
    private func queryMessages(_ messageIds: Dictionary<String, Any>.Keys,isAll: Bool = false,completion: @escaping (Result<[ChatMessage],Error>) -> Void) {
        var messages = [ChatMessage]()
        var messageDic = [String : ChatMessage]()
        let group = DispatchGroup()
        //  print("一共有\(messageIds.count)条聊天记录，分别是：\(messageIds)")
        messageIds.forEach { (messageId) in
            group.enter()
            // 拿着消息id去找该条消息的具体内容
            Firestore.firestore().collection(BBMessageKey).document(messageId).getDocument { (document, err) in
                if let err = err {
                    completion(.failure(err))
                }
                let message = ChatMessage.messageWithValues(document!.data()!)
                
                if !isAll {
                    // 和同一个人的消息只保留了最新的一条
                    if let curMessage = messageDic[message.partnerUid],curMessage.timestamp < message.timestamp {
                        messageDic[message.partnerUid] = message
                    } else if messageDic[message.partnerUid] == nil {
                        messageDic[message.partnerUid] = message
                    }
                } else {
                    messages.append(message)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            // 聊天列表中：保证刚刚发的信息排在最前面（倒序排列）
            if !isAll {
                messages = Array(messageDic.values).sorted(by: {$0.timestamp > $1.timestamp})
            } else {
                // 消息列表中消息是升序
                messages.sort(by: {$0.timestamp < $1.timestamp})
            }
            completion(.success(messages))
        }
    }
}
