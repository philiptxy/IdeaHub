//
//  Comment.swift
//  IdeaHub
//
//  Created by Philip Teow on 23/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import Foundation

class Comment {
    var commentID : String = ""
    var commentText : String = ""
    var timeStamp : Int = 0
    var userID : String = ""
    
    init() {
        
    }
    
    init(commentID : String, dict : [String : Any]) {
        self.commentID = commentID
        self.commentText = dict["commentText"] as? String ?? "No commentText in Class"
        self.timeStamp = dict["timeStamp"] as? Int ?? 0
        self.userID = dict["userID"] as? String ?? "No userID in Class"
    }
}
