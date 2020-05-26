//
//  UserListViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/26.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase

class UserListViewController: UITableViewController {

    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        
        fetchUsers()
        
    }

    func fetchUsers() {
        
        Firestore.firestore().collection("users").addSnapshotListener {[weak self] (snapshot, error) in
            guard let self = self else { return }
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            let username = documents.map { $0["username"]! }
            print("Current users : \(username)")
            
            let _ = documents.map { (document) in
                let user = User()
                user.uid = document.data()["uid"] as? String
                user.username = document.data()["username"] as? String
                user.iconUrl = document.data()["iconUrl"] as? String
                self.users.append(user)
            }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! UserCell
        let user = users[indexPath.row]
        cell.user = user
        return cell
    }

}

