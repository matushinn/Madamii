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
    var objectId: String
    var user: User
    var text: String
    var userCheck:String
    var replyCount:Int
    
    var createDate: Date
    var isLiked: Bool?
    var isBad: Bool?
    var likeCount: Int = 0
    var badCount: Int = 0
    var commentsCount:Int = 0
    
    
    init(postId: String, objectId: String, user: User, text: String,userCheck:String,replyCount:Int, createDate: Date) {
        self.postId = postId
        self.objectId = objectId
        self.user = user
        self.text = text
        self.userCheck = userCheck
        self.replyCount = replyCount
        self.createDate = createDate
    }
}
