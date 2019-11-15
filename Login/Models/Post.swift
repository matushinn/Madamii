//
//  Post.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/08.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

class Post {
    var objectId: String
    var user: User
    var imageUrl: String
    var postUrl:String
    var text: String
    var postComment:String
    
    var userCheck:String
    
    var rankCheck : Int
    var commentsCount : Int
    var createDate: Date
    var isLiked: Bool?
    var comments: [Comment]?
    var likeCount: Int = 0
    
    
    
    init(objectId: String, user: User, imageUrl: String, postUrl:String,text: String,postComment:String,userCheck:String,rankCheck:Int,commentsCount:Int, createDate: Date) {
        self.objectId = objectId
        self.user = user
        self.imageUrl = imageUrl
        self.postUrl = postUrl
        self.text = text
        self.postComment = postComment
        self.userCheck = userCheck
        self.rankCheck = rankCheck
        self.commentsCount = commentsCount
        self.createDate = createDate
    }
}
