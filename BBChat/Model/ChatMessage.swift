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
    var fromUid: String = ""
    var toUid: String = ""
    var timestamp: TimeInterval = 0
    
    var partnerUid: String {
        return FirebaseManager.shared.currentUser!.uid == fromUid ? toUid : fromUid
    }
    
    static func messageWithValues(_ values: [String : Any]) -> ChatMessage{
        let message = ChatMessage()
        message.fromUid = values["fromUid"] as! String
        message.toUid = values["toUid"] as! String
        message.timestamp = values["timestamp"] as! TimeInterval
        message.content = values["content"] as? String
        return message
    }
}
