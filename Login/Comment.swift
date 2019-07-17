//
//  Comment.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/17.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

class Comment {
    var postId: String
    var user: User
    var text: String
    var createDate: Date
    
    init(postId: String, user: User, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}
