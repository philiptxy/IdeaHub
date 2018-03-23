//
//  Functions.swift
//  IdeaHub
//
//  Created by Philip Teow on 22/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


class functions {

    var ref : DatabaseReference!

    init() {
        ref = Database.database().reference()
    }
    
    func getCurrentUserID() -> String {
        guard let id = Auth.auth().currentUser else {return ""}
        return id.uid
    }
    
    func getUserNameFromUid(uid : String) -> String{
        var name = "Fixname"
        
        ref.child("users/\(uid)/name").observeSingleEvent(of: .value, with: { (snapshot) in
            name = snapshot.value as! String
            
        })
        
        return name
        
    }
    
    enum actionType {
        case like
        case dislike
    //    case comment
    }
    
    func action( type : actionType, dict : [String : String] = [:], targetUid : String?){
        
        
        var path : String
        let userUid = getCurrentUserID()
//        let username = getUserNameFromUid(uid: userUid)
        
        
        switch type {
            
        case .like :
            path = "ideas/\(targetUid!)/likeby"
            ref.child(path).updateChildValues([userUid : true])
            break
            
//        case .unlike :
//            path = "ideas/\(targetUid!)/likeby"
//            self.deleteFromDatabase(path: path, item: userUid)
//            break
            
        case .dislike :
            path = "ideas/\(targetUid!)/dislikeby"
            ref.child(path).updateChildValues([userUid : true])
            break
            
//        case .comment :
//            path = "comments/\(targetUid!)"
//            self.modifyDatabase(path: path, dictionary: dict, autoId: true)
//            break
            
        default : break
            
        }
        
    }
        
        
        
        
//    func getProfilePicURL(userID: String) -> String {
//       var URL = ""
//        ref.child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
//            guard let dict = snapshot.value as? [String : Any] else {return}
//            URL = dict["profilePicURL"] as? String ?? ""
//
//        }
//        return URL
//    }
    
    
    
    
    
    
    
}
