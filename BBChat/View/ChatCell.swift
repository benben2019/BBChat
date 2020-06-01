//
//  ChatCell.swift
//  BBChat
//
//  Created by Ben on 2020/5/28.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

class ChatCell: UICollectionViewCell {
    
    let textLab: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .white
        lab.font = .chatFont
        lab.backgroundColor = .clear
        return lab
    }()
    
    let timeLab: UILabel = {
        let lab = UILabel()
        lab.numberOfLines = 0
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }()
    
    let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = .bubbleBlue
        v.layer.cornerRadius = 6
        v.clipsToBounds = true
        return v
    }()
    
    let iconView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.layer.cornerRadius = CGFloat.minBubbleHeight / 2
        icon.clipsToBounds = true
        icon.backgroundColor = .red
        return icon
    }()
    
    lazy var imageView: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFill
        imageV.layer.cornerRadius = 5
        imageV.clipsToBounds = true
        imageV.backgroundColor = UIColor(r: 236, g: 236, b: 236)
        imageV.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewImage(_:)))
        imageV.addGestureRecognizer(tap)
        return imageV
    }()
    
    var message: ChatMessage! {
        didSet {
            updateCell()
        }
    }
    
    var iconUrl: String? {
        didSet {
            iconView.loadCacheImage(iconUrl ?? "")
        }
    }
    
    var previewImageClosoure: ((CGRect,UIImageView) -> Void)?
    
    var bubbuleWidthConstraint: NSLayoutConstraint?
    var bubbuleLeftConstraint: NSLayoutConstraint?
    var bubbuleRightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(textLab)
        contentView.addSubview(iconView)
        bubbleView.addSubview(imageView)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        iconView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: .minBubbleHeight).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: .minBubbleHeight).isActive = true
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bubbuleRightConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        bubbuleLeftConstraint = bubbleView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor,constant: 5)
        bubbuleWidthConstraint = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: CGFloat.maxBubbleWidth)
        bubbuleLeftConstraint?.isActive = false
        bubbuleRightConstraint?.isActive = true
        bubbuleWidthConstraint?.isActive = true
        
        textLab.translatesAutoresizingMaskIntoConstraints = false
        textLab.topAnchor.constraint(equalTo: bubbleView.topAnchor,constant: UIEdgeInsets.chatBubbleInsets.top).isActive = true
        textLab.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,constant: -UIEdgeInsets.chatBubbleInsets.bottom).isActive = true
        textLab.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -UIEdgeInsets.chatBubbleInsets.right).isActive = true
        textLab.leadingAnchor.constraint(greaterThanOrEqualTo: bubbleView.leadingAnchor, constant: UIEdgeInsets.chatBubbleInsets.left).isActive = true
        textLab.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell() {
        //        cell.textLab.text = message.content
        textLab.attributedText = NSMutableAttributedString(string: message.content, attributes: chatTextAttibutes)
        //        cell.timeLab.text = message.timestamp.converToDateString(.longDate)
        bubbleView.backgroundColor = message.type == .text ? (message.isFromSelf ? .bubbleBlue : .bubbleGray) : .clear
        
        if message.type != .text {
            bubbuleWidthConstraint?.constant = .maxChatTextWidth
        } else {
            let width = ceil(message.content.textSize(.maxChatTextWidth, attributes: chatTextAttibutes).width) // 注意这里一定要向上取整，否则两个汉字的时候会显示不全
            if width + UIEdgeInsets.chatBubbleInsets.left + UIEdgeInsets.chatBubbleInsets.right < CGFloat.minBubbleWidth {
                bubbuleWidthConstraint?.constant = CGFloat.minBubbleWidth
            } else {
                bubbuleWidthConstraint?.constant = width + UIEdgeInsets.chatBubbleInsets.left + UIEdgeInsets.chatBubbleInsets.right
            }
        }
        
        
        bubbuleRightConstraint?.isActive = message.isFromSelf
        bubbuleLeftConstraint?.isActive = !message.isFromSelf
        textLab.textColor = message.isFromSelf ? .white : .black
        iconView.isHidden = message.isFromSelf
        
        textLab.isHidden = message.type != .text
        imageView.isHidden = message.type == .text
        imageView.loadCacheImage(message.imageUrl)
    }
}

extension ChatCell {
    @objc private func previewImage(_ tap: UITapGestureRecognizer) {
        if let imageView = tap.view, let closour = previewImageClosoure {
            let originFrame = imageView.superview?.convert(imageView.frame, to: nil)
            closour(originFrame!,(imageView as! UIImageView))
        }
    }
}
