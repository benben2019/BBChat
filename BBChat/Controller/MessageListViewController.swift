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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更多", style: .plain, target: self, action: #selector(moreClick))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "设置", style: .plain, target: self, action: #selector(showMenu))
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        
        observeLoginStatus()
    }
    
    func observeLoginStatus() {
        
        Auth.auth().addStateDidChangeListener { (auth, _) in
            var activity: UIActivityIndicatorView
            if #available(iOS 13.0, *) {
                activity = UIActivityIndicatorView(style: .medium)
            } else {
                // Fallback on earlier versions
                activity = UIActivityIndicatorView(style: .gray)
            }
            activity.hidesWhenStopped = true
            activity.startAnimating()
            self.navigationItem.titleView = activity
            
            if let user = auth.currentUser {
                FirebaseManager.shared.queryUser(user.uid) { (user) in
                    self.setTitleView(user)
                    self.bottomContainerController?.menuName = user.username
                }
                
                self.fetchMessageList()
                
            } else {
                activity.stopAnimating()
                self.navigationItem.titleView = nil
                self.messages.removeAll()
                self.tableView.reloadData()
                
                let nav = UINavigationController(rootViewController: MainPageViewController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    func setTitleView(_ user: User) {
        
        let iconUrl = user.iconUrl ?? ""
        
        let container = UIView()
        let iconImageView = UIImageView()
        iconImageView.layer.cornerRadius = 15
        iconImageView.clipsToBounds = true
        iconImageView.loadCacheImage(iconUrl)
        
        
        let nameLab = UILabel()
        nameLab.textColor = .black
        nameLab.font = UIFont.boldSystemFont(ofSize: 16)
        nameLab.text = user.username
        
        let iconSize: CGFloat = iconUrl.count > 0 ? 30 : 0.1
        let spacing: CGFloat = iconUrl.count > 0 ? 5 : 0
        container.hstack(iconImageView.withSize(.init(width: iconSize, height: iconSize)),nameLab,spacing: spacing,alignment: .center)
        
        self.navigationItem.titleView = container
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
        if FirebaseManager.shared.currentUser == nil {
            print("need login first!")
            return
        }
        navigationController?.pushViewController(UserListViewController(), animated: true)
    }
    
    @objc func showMenu() {
        bottomContainerController?.showMenu()
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        let uid = messages[indexPath.row].partnerUid
        FirebaseManager.shared.queryUser(uid) {[weak self] (user) in
            let chatVc = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
            chatVc.user = user
            self?.navigationController?.pushViewController(chatVc, animated: true)
        }
    }
}
