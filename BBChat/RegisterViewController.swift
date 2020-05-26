//
//  RegisterViewController.swift
//  BBChat
//
//  Created by Ben on 2020/5/22.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    let usernameTextField = UITextField()
    let emailTextField = UITextField()
    let passwordField = UITextField()
    let regisBtn = UIButton(type: .custom)
    let iconBtn = UIButton(type: .custom)
    
    var uid: String?
    var iconUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        setupTextField(usernameTextField).placeholder = "请输入昵称"
        setupTextField(emailTextField).placeholder = "请输入邮箱"
        setupTextField(passwordField).placeholder = "请输入密码"
        
        regisBtn.backgroundColor = .cyan
        regisBtn.layer.borderColor = UIColor.black.cgColor
        regisBtn.layer.borderWidth = 2
        regisBtn.layer.cornerRadius = 10
        regisBtn.clipsToBounds = true
        regisBtn.setTitle("开始注册", for: .normal)
        regisBtn.addTarget(self, action: #selector(beginRegister), for: .touchUpInside)
        
        iconBtn.layer.borderWidth = 2
        iconBtn.layer.cornerRadius = 50
        iconBtn.layer.borderColor = UIColor.lightGray.cgColor
        iconBtn.clipsToBounds = true
        iconBtn.setTitle("+", for: .normal)
        iconBtn.setTitleColor(.lightGray, for: .normal)
        iconBtn.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        iconBtn.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
        iconBtn.imageView!.contentMode = .scaleAspectFill
        
        view.stack(UIView().hstack(UIView(),iconBtn.withSize(.init(width: 100, height: 100)),UIView(), distribution: .equalCentering),
                   UIView().withHeight(40),
                   usernameTextField.withHeight(44),
                   UIView().withHeight(20),
                   emailTextField.withHeight(44),
                   UIView().withHeight(20),
                   passwordField.withHeight(44),
                   UIView().withHeight(60),
                   regisBtn.withHeight(45),
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
    
    @objc func beginRegister() {
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            username.count > 0,
            email.count > 0,
            password.count > 0 else {
                print("信息未完善！")
                alert("信息未完善！")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] (result, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.uid = result!.user.uid
            self.dismiss(animated: true, completion: nil)
            
            let db = Firestore.firestore()
            let data: [String : Any] = ["username" : username,"uid" : result!.user.uid,"iconUrl" : self.iconUrl ?? ""]
            db.collection("users").addDocument(data: data) { (err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    print("用户 \(username) - \(result!.user.uid) 已存入数据库！")
                }
            }
        }
    }
    
    @objc func iconTapped() {
        print("iconTapped")
        let pickerVc = UIImagePickerController()
        pickerVc.allowsEditing = true
        pickerVc.delegate = self
        present(pickerVc, animated: true, completion: nil)
    }
    
    fileprivate func updateUserinfo(_ uid: String,values: [String: Any]) {
        Firestore.firestore().collection("users").document(uid).updateData(values) { (error) in
            if let error = error {
                print("更新头像失败！ :",error.localizedDescription)
                self.alert("更新头像失败！ :,\(error.localizedDescription)")
            } else {
                print("头像更新成功！")
                self.alert("头像更新成功！")
            }
        }
    }
    
    fileprivate func uploadImage(_ image: UIImage) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("images/" + "\(imageName).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
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
                self.iconUrl = downloadURL.absoluteString
                
                if let userId = self.uid {
                    self.updateUserinfo(userId, values: ["iconUrl": downloadURL.absoluteString])
                }
                
                do {
                    let data = try NSData(contentsOf: downloadURL, options: .alwaysMapped)
                    let image = UIImage(data: data as Data)
                    self.iconBtn.setImage(image, for: .normal)
                } catch {
                    print(error.localizedDescription)
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

extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            uploadImage(editImage)
        } else if let oriImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            uploadImage(oriImage)
        }
    }
}
