//
//  LoginViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/22.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

      let emailTextField = UITextField()
      let passwordField = UITextField()
      let loginBtn = UIButton(type: .custom)
      
      override func viewDidLoad() {
          super.viewDidLoad()

          // Do any additional setup after loading the view.
          view.backgroundColor = .white
          
          setupTextField(emailTextField).placeholder = "请输入邮箱"
          setupTextField(passwordField).placeholder = "请输入密码"
          
          loginBtn.backgroundColor = .cyan
          loginBtn.layer.borderColor = UIColor.black.cgColor
          loginBtn.layer.borderWidth = 2
          loginBtn.layer.cornerRadius = 10
          loginBtn.clipsToBounds = true
          loginBtn.setTitle("登录", for: .normal)
          loginBtn.addTarget(self, action: #selector(beginLogin), for: .touchUpInside)
          
          view.stack(
                     emailTextField.withHeight(44),
                     UIView().withHeight(20),
                     passwordField.withHeight(44),
                     UIView().withHeight(60),
                     loginBtn.withHeight(45),
                     UIView())
          .padTop(60)
          .padLeft(30)
          .padRight(30)
      }
      
      @discardableResult
      private func setupTextField(_ f: UITextField) -> UITextField {
          f.layer.borderColor = UIColor(r: 100, g: 10, b: 180).cgColor
          f.layer.borderWidth = 2
          f.layer.cornerRadius = 10
          f.clipsToBounds = true
          f.leftView = UIView().withWidth(15)
          f.leftViewMode = .always
          f.font = UIFont.systemFont(ofSize: 14)
          return f
      }
    
      override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          view.endEditing(true)
      }
    
    @objc func beginLogin() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            email.count > 0,
            password.count > 0 else {
                print("信息未完善！")
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] (result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            print("登录成功！")
            
            self?.dismiss(animated: true, completion: nil)
            
        }
    }
    


}
