//
//  User.swift
//  IdeaHub
//
//  Created by Philip Teow on 23/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import Foundation

class User {
    
    var userID : String = ""
    var email : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var profilePicURL : String = ""
    var numOfUnstarted : Int = 0
    var numOfInProgress : Int = 0
    var numOfIncomplete : Int = 0
    var numOfComplete : Int = 0
    
    init() {
        
    }
    
    init(userID: String, dict: [String: Any]) {
        self.userID = userID
        self.email = dict["email"] as? String ?? ""
        self.firstName = dict["firstName"] as? String ?? ""
        self.lastName = dict["lastName"] as? String ?? ""
        self.profilePicURL = dict["profilePicURL"] as? String ?? ""
        self.numOfUnstarted = dict["numOfUnstarted"] as? Int ?? 0
        self.numOfInProgress = dict["numOfInProgress"] as? Int ?? 0
        self.numOfIncomplete = dict["numOfIncomplete"] as? Int ?? 0
        self.numOfComplete = dict["numOfComplete"] as? Int ?? 0


    }
}
