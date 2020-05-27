//
//  HomeViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/22.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase

class MessageListViewController: UITableViewController {

    var messages = [ChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "more", style: .plain, target: self, action: #selector(moreClick))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutClick))
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        
        observeLoginStatus()
        checkLoginStatus()
    }
    
    func observeLoginStatus() {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let activity = UIActivityIndicatorView(style: .medium)
            activity.hidesWhenStopped = true
            activity.startAnimating()
            self.navigationItem.titleView = activity
            
            if let user = user {
                Firestore.firestore().collection(BBUserKey).whereField("uid", isEqualTo: user.uid).getDocuments { (documents, error) in
                    activity.stopAnimating()
                    if let documents = documents?.documents,let curUser = documents.first?.data() {
                        let iconUrl = curUser["iconUrl"] as? String
                        let username = curUser["username"] as! String
                        self.setTitleView(iconUrl ?? "", username: username)
                    } else {
                        print("nothing queryed")
                        self.navigationItem.titleView = nil
                    }
                }
                
                self.fetchMessageList()
                
            } else {
                activity.stopAnimating()
                self.navigationItem.titleView = nil
            }
        }
    }
    
    func setTitleView(_ iconUrl: String,username: String) {
        let container = UIView()
        let iconImageView = UIImageView()
        iconImageView.layer.cornerRadius = 15
        iconImageView.clipsToBounds = true
        iconImageView.loadCacheImage(iconUrl)
        
        
        let nameLab = UILabel()
        nameLab.textColor = .black
        nameLab.font = UIFont.boldSystemFont(ofSize: 16)
        nameLab.text = username
        
        let iconSize: CGFloat = iconUrl.count > 0 ? 30 : 0.1
        let spacing: CGFloat = iconUrl.count > 0 ? 5 : 0
        container.hstack(iconImageView.withSize(.init(width: iconSize, height: iconSize)),nameLab,spacing: spacing,alignment: .center)
        
        self.navigationItem.titleView = container
    }
    
    func checkLoginStatus() {
        if let currentUid = Auth.auth().currentUser?.uid { // 已登录
            print(currentUid)
        } else {
            let nav = UINavigationController(rootViewController: MainPageViewController())
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    func fetchMessageList() {
        FirebaseManager.shared.fetchChatList {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                self.messages = messages
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func moreClick() {
        if Auth.auth().currentUser == nil {
            print("need login first!")
            return
        }
        navigationController?.pushViewController(UserListViewController(), animated: true)
    }
    
    @objc func logoutClick() {
        do {
            try Auth.auth().signOut()
            let nav = UINavigationController(rootViewController: MessageListViewController())
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension MessageListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
//        let chatVc = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
//        chatVc.user = users[indexPath.row]
//        navigationController?.pushViewController(chatVc, animated: true)
    }
}
