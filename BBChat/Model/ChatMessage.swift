//
//  ChatMessage.swift
//  BBChat
//
//  Created by Ben on 2020/5/27.
//  Copyright © 2020 Benben. All rights reserved.
//

import Foundation
import UIKit

enum MessageType {
    case text,image,video
}

class ChatMessage: NSObject {
    var content: String = ""
    var fromUid: String = ""
    var toUid: String = ""
    var timestamp: TimeInterval = 0
    var imageUrl: String = ""
    var videoUrl: String = ""
    var coverImageUrl: String = ""
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    
    var partnerUid: String {
        return FirebaseManager.shared.currentUser!.uid == fromUid ? toUid : fromUid
    }
    
    var type: MessageType {
        if videoUrl.count > 0 {
            return .video
        } else if imageUrl.count > 0 {
            return .image
        } else {
            return .text
        }
    }
    
    var isFromSelf: Bool {
        return fromUid == FirebaseManager.shared.currentUser!.uid
    }
    
    static func messageWithValues(_ values: [String : Any]) -> ChatMessage {
        let message = ChatMessage()
        message.fromUid = values["fromUid"] as! String
        message.toUid = values["toUid"] as! String
        message.timestamp = values["timestamp"] as! TimeInterval
        message.content = values["content"] as! String
        message.imageUrl = values["imageUrl"] as! String
        message.videoUrl = values["videoUrl"] as! String
        message.coverImageUrl = values["coverImageUrl"] as! String
        message.imageWidth = values["imageWidth"] as! CGFloat
        message.imageHeight = values["imageHeight"] as! CGFloat
        return message
    }
}
