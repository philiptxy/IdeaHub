//
//  Idea.swift
//  IdeaHub
//
//  Created by Philip Teow on 23/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import Foundation

class Idea {
    
    var ideaID : String = ""
    var description: String = ""
    var lat : Double = 0
    var locationName : String = ""
    var long : Double = 0
    var name : String = ""
    var postedPicURL : String = ""
    var posterID : String = ""
    var progress : String = ""
    var timeStamp : Int = 0
    
    init() {
        
    }
    
    init(ideaID : String, dict : [String : Any]) {
        self.ideaID = ideaID
        self.description = dict["description"] as? String ?? ""
        self.lat = dict["lat"] as? Double ?? 0
        self.locationName = dict["locationName"] as? String ?? ""
        self.long = dict["long"] as? Double ?? 0
        self.name = dict["name"] as? String ?? ""
        self.postedPicURL = dict["postedPicURL"] as? String ?? ""
        self.posterID = dict["posterID"] as? String ?? ""
        self.progress = dict["progress"] as? String ?? ""
        self.timeStamp = dict["timeStamp"] as? Int ?? 0
    }
    
}
