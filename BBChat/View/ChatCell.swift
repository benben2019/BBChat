//
//  ChatCell.swift
//  BBChat
//
//  Created by Ben on 2020/5/28.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    lazy var playBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "player_play")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        return btn
    }()
    
    let activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        activity.hidesWhenStopped = true
        return activity
    }()
    
    var player: AVPlayer?
    var playLayer: AVPlayerLayer?
    
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
        bubbleView.addSubview(playBtn)
        bubbleView.addSubview(activity)
        
        layout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEndPlayVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // cell复用的时候将layer移除，同时停止播放
        player?.pause()
        playLayer?.removeFromSuperlayer()
        activity.stopAnimating()
    }
    
    private func layout() {
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
        
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        playBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playBtn.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playBtn.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
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
        imageView.loadCacheImage(message.type == .image ? message.imageUrl : message.coverImageUrl)
        playBtn.isHidden = message.type != .video
    }
}

extension ChatCell {
    @objc private func previewImage(_ tap: UITapGestureRecognizer) {
        if message.type == .video { return }
        if let imageView = tap.view, let closour = previewImageClosoure {
            let originFrame = imageView.superview?.convert(imageView.frame, to: nil)
            closour(originFrame!,(imageView as! UIImageView))
        }
    }
    
    @objc private func playVideo() {
        
//        playBtn.isHidden = true
        activity.startAnimating()
        
        let asset = AVAsset(url: URL(string: message.videoUrl)!)
        print("该视频时长：\(asset.duration.value / Int64(asset.duration.timescale))s")
        let playItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playItem)
        playLayer = AVPlayerLayer(player: player)
        playLayer!.frame = imageView.bounds
        bubbleView.layer.addSublayer(playLayer!)
        
        player?.play()
    }
    
    @objc private func didEndPlayVideo() {
        if player == nil { return }
//        playBtn.isHidden = false
        player?.seek(to: .zero)
        activity.stopAnimating()
        playLayer?.removeFromSuperlayer()
    }
}
