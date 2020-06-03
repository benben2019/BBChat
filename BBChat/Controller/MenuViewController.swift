//
//  MenuViewController.swift
//  BBChat
//
//  Created by Ben on 2020/6/3.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController {

    let nameLab: UILabel = {
        let nameLab = UILabel()
        nameLab.font = .boldSystemFont(ofSize: 30)
        nameLab.text = "baobao"
        nameLab.textColor = .bubbleBlue
        nameLab.textAlignment = .center
        return nameLab
    }()
    
    lazy var headerView: UIView = {
        let header = UIView()
        header.stack(nameLab.withHeight(44))
        return header
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        table.tableFooterView = UIView()
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    lazy var tableFooter: UIView = {
        let footer = UIView()
        
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 8
        btn.clipsToBounds = true
        btn.setTitle("退出登录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.backgroundColor = .buttonRed
        btn.addTarget(self, action: #selector(logoutClick), for: .touchUpInside)
        footer.stack(UIView(),btn.withSize(.init(width: 80, height: 40)),alignment: .center)
        
        return footer
    }()
    
    var name: String? {
        didSet {
            nameLab.text = name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.stack(UIView().withHeight(kStatusBarHeight),headerView,tableView)
    }
    
    @objc func logoutClick() {
        alertLogout {
            do {
                try Auth.auth().signOut()
                self.bottomContainerController?.hideMenu()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension MenuViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")!
        cell.textLabel?.text = "cell \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        bottomContainerController?.hideMenu()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableFooter
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 150
    }
}
