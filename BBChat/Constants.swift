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
