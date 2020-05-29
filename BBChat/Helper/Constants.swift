//
//  Constants.swift
//  BBChat
//
//  Created by Ben on 2020/5/27.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

var iPhoneX: Bool {
    let safeBottom = UIApplication.shared.delegate?.window!!.safeAreaInsets.bottom
    return safeBottom! > 0
}

var kBottomSafeHeight: CGFloat = iPhoneX ? 34 : 0

var BBMessageKey: String = "messages"
var BBUserMessageKey: String = "user_messages"
var BBUserKey: String = "users"

var chatTextAttibutes: [NSAttributedString.Key : Any] {
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 2
    return [.font: UIFont.chatFont,.paragraphStyle : style]
}

extension CGFloat {
    static let maxBubbleWidth: CGFloat = 240
    static let minBubbleWidth: CGFloat = 40
    static let minBubbleHeight: CGFloat = 38
    static let maxChatTextWidth: CGFloat = maxBubbleWidth - UIEdgeInsets.chatBubbleInsets.left - UIEdgeInsets.chatBubbleInsets.right
}

extension UIFont {
    static let chatFont: UIFont = UIFont.systemFont(ofSize: 15)
}

extension UIEdgeInsets {
    static let chatBubbleInsets: UIEdgeInsets = .init(top: 5, left: 8, bottom: 5, right: 8)
}

extension String {
    static let shortDate = "hh:mm:ss a"
    static let longDate = "MM-dd hh:mm a"
}

extension UIColor {
    static let buttonRed = UIColor(r: 158, g: 88, b: 92)
    static let bubbleBlue = UIColor(r: 0, g: 137, b: 249)
    static let bubbleGray = UIColor(r: 220, g: 220, b: 220)
}
