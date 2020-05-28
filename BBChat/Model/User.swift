//
//  User.swift
//  BBChat
//
//  Created by Ben on 2020/5/26.
//  Copyright © 2020 Benben. All rights reserved.
//

import Foundation

class User: NSObject {
    var uid: String = ""
    var username: String = ""
    var iconUrl: String?
    
    static func userWithValues(values: [String : Any]) -> User {
        let user = User()
        user.uid = values["uid"] as! String
        user.username = values["username"] as! String
        user.iconUrl = values["iconUrl"] as? String
        return user
    }
}
