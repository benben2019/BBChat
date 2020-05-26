//
//  ViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/22.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import AVKit
import Firebase

class MessageListViewController: UIViewController {

    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.isHidden = true
        
        let registerBtn = UIButton(type: .custom)
        registerBtn.backgroundColor = UIColor(r: 220, g: 30, b: 30)
        registerBtn.setTitle("注册", for: .normal)
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
        registerBtn.addTarget(self, action: #selector(enterRegisterViewController), for: .touchUpInside)
        view.addSubview(registerBtn)
        
        let loginBtn = UIButton(type: .custom)
        loginBtn.backgroundColor = .clear
        loginBtn.layer.borderColor = UIColor.black.cgColor
        loginBtn.layer.borderWidth = 2
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.setTitleColor(.black, for: .normal)
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        loginBtn.addTarget(self, action: #selector(enterLoginViewController), for: .touchUpInside)
        view.addSubview(loginBtn)
        
        view.stack(UIView(),
                   registerBtn.withHeight(45),
                   UIView().withHeight(15),
                   loginBtn.withHeight(45)
            ).padRight(80)
            .withAllSide(50)
        
        let playItem = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "cat.mp4", ofType: nil)!))
        player = AVPlayer(playerItem: playItem)
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.layer.insertSublayer(layer, at: 0)
        
        player.playImmediately(atRate: 0.6)
        
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) {[weak self] (noti) in
            guard let self = self else { return }
            
            self.player.seek(to: .zero) {_ in}
            self.player.playImmediately(atRate: 0.6)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension MessageListViewController {
    @objc func enterLoginViewController() {
        navigationController?.pushViewController(LoginViewController(), animated: true)
    }
    @objc func enterRegisterViewController() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
}
