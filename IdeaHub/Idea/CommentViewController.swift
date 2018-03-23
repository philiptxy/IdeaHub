//
//  CommentViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 23/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CommentViewController: UIViewController {
    
    @IBOutlet weak var currentUserImageView: UIImageView! {
        didSet {
            currentUserImageView.layer.borderWidth = 1.0
            currentUserImageView.layer.masksToBounds = false
            currentUserImageView.layer.borderColor = UIColor.white.cgColor
            currentUserImageView.layer.cornerRadius = currentUserImageView.frame.size.width / 2
            currentUserImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.rowHeight = 70
        }
    }
    
    
    var selectedIdea : Idea = Idea()
    var comments : [Comment] = []
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        loadCurrentUserPic()
        observeComments()
    }
    
    
    func loadCurrentUserPic() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        ref.child("users").child(currentUserID).child("profilePicURL").observeSingleEvent(of: .value) { (snapshot) in
            let currentUserProfilePicURL = snapshot.value as? String ?? "No profilepic in snapshot"
            
            if let imageViewForCell = self.currentUserImageView {
                self.getImage(currentUserProfilePicURL, imageViewForCell)
            }
        }
    }
    
    func observeComments(){
        ref.child("comments").child(selectedIdea.ideaID).queryOrdered(byChild: "timeStamp").observe(.childAdded) { (snapshot) in
            //guard let commentDict = snapshot.value as? [String : Any] else {return}
            
            if let commentDict = snapshot.value as? [String:Any] {
                DispatchQueue.main.async {
                    let aComment = Comment(commentID: snapshot.key, dict: commentDict)
                    self.comments.append(aComment)
                    self.tableView.reloadData()
//                    let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
//                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
            
        }
    }
    
    @objc func sendButtonTapped() {
        guard let inputText = commentTextField.text else {return}
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        let currentDateTime = Date()
        
        // get the user's calendar
        let userCalendar = Calendar.current
        
        // choose which date and time components are needed
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
        
        guard let year = dateTimeComponents.year?.stringValue,
            var month = dateTimeComponents.month?.stringValue,
            var day = dateTimeComponents.day?.stringValue,
            var hour = dateTimeComponents.hour?.stringValue,
            var minute = dateTimeComponents.minute?.stringValue,
            var second = dateTimeComponents.second?.stringValue else {return}
        
        
        
        if let number = Int(month) {
            if (number / 10) < 1 {
                month = "0" + month
            }
        }
        if let number = Int(day) {
            if (number / 10) < 1 {
                day = "0" + day
            }
        }
        if let number = Int(hour) {
            if (number / 10) < 1 {
                hour = "0" + hour
            }
        }
        if let number = Int(minute) {
            if (number / 10) < 1 {
                minute = "0" + minute
            }
        }
        if let number = Int(second) {
            if (number / 10) < 1 {
                second = "0" + second
            }
        }
        
        let currentTime : String = year + month + day + hour + minute + second
        
        guard let currentTimeInt = Int(currentTime) else {return}
        print(currentTimeInt)
        
        let currentComment = ref.child("comments").child(selectedIdea.ideaID).childByAutoId()
        
        let commentPlaceholder : [String : Any] = ["commentText" : inputText, "userID" : currentUserID, "timeStamp" : currentTimeInt]
        
        ref.child("comments").child(selectedIdea.ideaID).child(currentComment.key).setValue(commentPlaceholder)
        
        commentTextField.text = ""
        
    }
    
}

extension CommentViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CommentTableViewCell else {return UITableViewCell()}
        let currentComment = comments[indexPath.row]
        
        ref.child("users").child(currentComment.userID).child("profilePicURL").observeSingleEvent(of: .value) { (snapshot) in
            let commenterProfilePicURL = snapshot.value as? String ?? "No profilepic in snapshot"
            
            if let imageViewForCell = cell.profileImageView {
                self.getImage(commenterProfilePicURL, imageViewForCell)
            }
        }
        
        ref.child("users").child(currentComment.userID).child("firstName").observeSingleEvent(of: .value) { (snapshot) in
            let commenterName = snapshot.value as? String ?? "No username in snapshot"
            
            cell.nameLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            
            cell.nameLabel.text = commenterName
            
        }
        
        cell.commentLabel.text = currentComment.commentText
        
        cell.selectionStyle = .none
        
        return cell
    }

    
}

extension Int {
    var stringValue:String {
        return "\(self)"
    }
}



