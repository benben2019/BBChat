//
//  InputBar.swift
//  BBChat
//
//  Created by Ben on 2020/6/4.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

class InputBar: UIView {
    
    var maxLines: CGFloat = 5
    private var minLineHeight: CGFloat {
        return ceil(inputTextView.font!.lineHeight)
    }
    var placeholder: String = "" {
        didSet {
            placeholderLab.text = placeholder
        }
    }
    
    var inputText: String? {
        set {
            inputTextView.text = newValue
            placeholderLab.isHidden = inputText?.count != 0
            if inputText?.count == 0 {
                textViewHeightConstraint?.constant = minLineHeight
            }
        }
        get {
            inputTextView.text
        }
    }
    
    private let placeholderLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 15)
        lab.textColor = .darkGray
        lab.text = "说点什么吧..."
        return lab
    }()
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.tintColor = .black
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.font = .systemFont(ofSize: 14)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return btn
    }()
    
    let mediaPickButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.addTarget(self, action: #selector(mediaPick), for: .touchUpInside)
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = UIColor.systemBlue.cgColor
        btn.layer.borderWidth = 1
        btn.titleLabel?.font = .systemFont(ofSize: 20)
        return btn
    }()
    
    lazy var textViewContainer: UIView = {
        let textViewContainer = UIView()
        textViewContainer.layer.cornerRadius = 5
        textViewContainer.clipsToBounds = true
        textViewContainer.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        textViewContainer.layer.borderWidth  = 0.8
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        textViewContainer.addGestureRecognizer(tap)
        return textViewContainer
    }()
    
    let bottomSpaceView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    private let topLine = UIView()
    private let keyboardListener = KeyboardListener()
    
    var textViewHeightConstraint: NSLayoutConstraint?
    var bottomSpaceHeightConstraint: NSLayoutConstraint?
    
    var sendButtonClosoure: (() -> Void)?
    var imagePickerClosoure: (() -> Void)?
    var barWillMoveUpCallback: ((CGFloat,Double) -> Void)?
    var barWillMoveDownCallback: ((Double) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        topLine.backgroundColor = UIColor(r: 227, g: 230, b: 225)
        addSubview(topLine)
        addSubview(mediaPickButton)
        addSubview(textViewContainer)
        addSubview(sendButton)
        addSubview(bottomSpaceView)
        
        layout()
        
        keyboardListener.keyboardWillShowCallback = {[weak self] (keyboardHeight,duration) in
            self?.bottomSpaceHeightConstraint?.constant = 0.1
            if let callback = self?.barWillMoveUpCallback {
                callback(keyboardHeight,duration)
            }
        }
        keyboardListener.keyboardWillHideCallback = {[weak self] (duration) in
            self?.bottomSpaceHeightConstraint?.constant = kBottomSafeHeight
            if let callback = self?.barWillMoveDownCallback {
                callback(duration)
            }
        }
    }
    
    private func layout() {
        topLine.translatesAutoresizingMaskIntoConstraints = false
        topLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        topLine.topAnchor.constraint(equalTo: bottomAnchor).isActive = true
        topLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        topLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        textViewContainer.hstack(inputTextView,alignment: .center).withAllSide(10)
        textViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: minLineHeight)
        textViewHeightConstraint?.isActive = true
        
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        textViewContainer.leadingAnchor.constraint(equalTo: mediaPickButton.trailingAnchor, constant: 5).isActive = true
        textViewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        
        mediaPickButton.translatesAutoresizingMaskIntoConstraints = false
        mediaPickButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        mediaPickButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        mediaPickButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        mediaPickButton.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor).isActive = true
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.leadingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: 5).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        
        inputTextView.addSubview(placeholderLab)
        placeholderLab.translatesAutoresizingMaskIntoConstraints = false
        placeholderLab.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor).isActive = true
        placeholderLab.trailingAnchor.constraint(equalTo: inputTextView.trailingAnchor).isActive = true
        placeholderLab.centerYAnchor.constraint(equalTo: inputTextView.centerYAnchor).isActive = true
        
        bottomSpaceView.translatesAutoresizingMaskIntoConstraints = false
        bottomSpaceView.topAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: 5).isActive = true
        bottomSpaceView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomSpaceView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomSpaceView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomSpaceHeightConstraint = bottomSpaceView.heightAnchor.constraint(equalToConstant: kBottomSafeHeight)
        bottomSpaceHeightConstraint?.isActive = true
        
        //        stack(line.withHeight(1),
        //              UIView().hstack(UIView().withWidth(5),
        //                              mediaPickButton.withSize(.init(width: 30, height: 30)),
        //                              UIView().stack(textViewContainer).padTop(5).padBottom(5),
        //                              sendButton.withWidth(50).withHeight(50),
        //                              spacing: 5,
        //                              alignment: .center))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewResignFirstResponder() {
        inputTextView.resignFirstResponder()
    }
    
    @objc private func handleTap() {
        inputTextView.becomeFirstResponder()
    }
    
    @objc private func sendMessage() {
        if let callback = sendButtonClosoure {
            callback()
        }
    }
    
    @objc private func mediaPick() {
        if let callback = imagePickerClosoure {
            callback()
        }
    }
    
}

extension InputBar: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let frame = textView.frame
//        let constrainSize = CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        var height = ceil(textView.text.textSize(frame.size.width, attributes: [NSAttributedString.Key.font: textView.font as Any]).height)
//        let oneLineHeight = ceil(textView.font!.lineHeight)
        let numberOfLines = ceil(height / minLineHeight)
        print(height,numberOfLines,minLineHeight)
        
        let contentMaxHeight: CGFloat = minLineHeight * maxLines
        if height >= contentMaxHeight {
            height = contentMaxHeight
        }
        
        textViewHeightConstraint?.constant = height
        
        placeholderLab.isHidden = textView.text.count > 0
    }
}

class KeyboardListener {
    
    fileprivate var keyboardWillShowCallback: ((CGFloat,Double) -> Void)?
    fileprivate var keyboardWillHideCallback: ((Double) -> Void)?
    
    init() {
        addKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ noti: Notification) {
        if let userInfo = noti.userInfo {
            let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            print(#function)
            if let callback = keyboardWillShowCallback {
                callback(height,duration)
            }
//            inputTextViewBottomConstraint?.constant = -height
//            collectionViewTopConstraint?.constant = -height
//            UIView.animate(withDuration: duration) {
//                self.view.layoutIfNeeded()
//            }
//            self.scrollToBottom(true)
        }
    }
    
    @objc private func keyboardWillHide(_ noti: Notification) {
        if let userInfo = noti.userInfo {
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            print(#function)
            if let callback = keyboardWillHideCallback {
                callback(duration)
            }
//            inputTextViewBottomConstraint?.constant = 0
//            collectionViewTopConstraint?.constant = 0
//            UIView.animate(withDuration: duration) {
//                self.view.layoutIfNeeded()
//            }
        }
    }
}
