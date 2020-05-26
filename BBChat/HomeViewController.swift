//
//  HomeViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/22.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "more", style: .plain, target: self, action: #selector(moreClick))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "logout", style: .plain, target: self, action: #selector(logoutClick))
        
        view.backgroundColor = .white
        
        observeLoginStatus()
        checkLoginStatus()
    }
    
    func observeLoginStatus() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                Firestore.firestore().collection("users").whereField("uid", isEqualTo: user.uid).getDocuments { (documents, error) in
                    if let documents = documents?.documents,let curUser = documents.first?.data() {
                        let iconUrl = curUser["iconUrl"] as! String
                        let username = curUser["username"] as! String
                        self.setTitleView(iconUrl, username: username)
                    } else {
                        print("nothing queryed")
                        self.navigationItem.titleView = nil
                    }
                }
            } else {
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
        
        container.hstack(iconImageView.withSize(.init(width: 30, height: 30)),nameLab,spacing: 5,alignment: .center)
        
        self.navigationItem.titleView = container
    }
    
    func checkLoginStatus() {
        if let currentUid = Auth.auth().currentUser?.uid { // 已登录
            print(currentUid)
        } else {
            let nav = UINavigationController(rootViewController: MessageListViewController())
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
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
