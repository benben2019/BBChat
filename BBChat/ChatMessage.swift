//
//  ChatMessage.swift
//  BBChat
//
//  Created by Ben on 2020/5/27.
//  Copyright © 2020 Benben. All rights reserved.
//

import Foundation

class ChatMessage: NSObject {
    var content: String?
    var fromUid: String?
    var toUid: String?
    var timestamp: TimeInterval?
}
