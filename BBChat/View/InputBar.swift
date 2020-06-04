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
    var placeholder: String = "" {
        didSet {
            placeholderLab.text = placeholder
        }
    }
    
    var inputText: String? {
        set {
            inputTextfield.text = newValue
        }
        get {
            inputTextfield.text
        }
    }
    
    private let placeholderLab: UILabel = {
        let lab = UILabel()
        lab.font = .systemFont(ofSize: 15)
        lab.textColor = .darkGray
        lab.text = "说点什么吧..."
        return lab
    }()
    
    private lazy var inputTextfield: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.tintColor = .black
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.font = .systemFont(ofSize: 14)
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        //            btn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return btn
    }()
    
    let mediaPickButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        //            btn.addTarget(self, action: #selector(mediaPick), for: .touchUpInside)
        btn.layer.cornerRadius = 15
        btn.layer.borderColor = UIColor.systemBlue.cgColor
        btn.layer.borderWidth = 1
        btn.titleLabel?.font = .systemFont(ofSize: 20)
        return btn
    }()
    
    var textViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        let line = UIView().withHeight(1)
        line.backgroundColor = UIColor(r: 227, g: 230, b: 225)
        
        let textViewContainer = UIView()
        textViewContainer.layer.cornerRadius = 5
        textViewContainer.clipsToBounds = true
        textViewContainer.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
        textViewContainer.layer.borderWidth  = 0.8
        textViewContainer.hstack(inputTextfield,alignment: .center).withAllSide(10)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        textViewContainer.addGestureRecognizer(tap)
        
        inputTextfield.stack(placeholderLab)
        
        textViewHeightConstraint = inputTextfield.heightAnchor.constraint(greaterThanOrEqualToConstant: 17)
        textViewHeightConstraint?.isActive = true
        stack(line,
              UIView().hstack(UIView().withWidth(5),
                              mediaPickButton.withSize(.init(width: 30, height: 30)),
                              UIView().stack(textViewContainer).padTop(5).padBottom(5),
                              sendButton.withWidth(50).withHeight(50),
                              spacing: 5,
                              alignment: .center))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewResignFirstResponder() {
        inputTextfield.resignFirstResponder()
    }
    
    @objc private func handleTap() {
        inputTextfield.becomeFirstResponder()
    }
}

extension InputBar: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let frame = textView.frame
//        let constrainSize = CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        var height = ceil(textView.text.textSize(frame.size.width, attributes: [NSAttributedString.Key.font: textView.font as Any]).height)
        let oneLineHeight = ceil(textView.font!.lineHeight)
        let numberOfLines = ceil(height / oneLineHeight)
        print(height,numberOfLines,oneLineHeight)
        
        let contentMaxHeight: CGFloat = oneLineHeight * maxLines
        if height >= contentMaxHeight {
            height = contentMaxHeight
        }
        
        textViewHeightConstraint?.constant = height
        
        placeholderLab.isHidden = textView.text.count > 0
    }
}

