//
//  DetailViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 22/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DetailViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var postedPicImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    
    
    //------------------------ Global Variable ----------------------
    
    var ref : DatabaseReference!
    
    var selectedIdea : Idea = Idea()
    
    
    //------------------------- viewDidLoad ----------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        giveValue()
    }
    
    func giveValue() {
        
       
        
        let formatterFrom = DateFormatter()
        formatterFrom.dateFormat = "yyyyMMddHHmmss"
        
        let time = String(selectedIdea.timeStamp)
        guard let dateFrom = formatterFrom.date(from: time) else {return}
        
        let formatterTo = DateFormatter()
        formatterTo.dateFormat = "dd MMMM yyyy HH:mm a"
        let date = formatterTo.string(from: dateFrom)
        ref.child("users").child(selectedIdea.posterID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else {return}
            let poster = User(userID: snapshot.key, dict: dict)
            
            DispatchQueue.main.async {
                self.titleLabel.text = self.selectedIdea.name
                self.getImage(self.selectedIdea.postedPicURL, self.postedPicImageView)
                self.descriptionLabel.text = self.selectedIdea.description
                self.getImage(poster.profilePicURL, self.profilePicImageView)
                self.nameLabel.text = "\(poster.firstName) \(poster.lastName)"
                self.dateLabel.text = date
                self.progressLabel.text = self.selectedIdea.progress
                //TODO: number of likes
            }
            
            
        }
        
        
        //nameLabel.text =
        
        
    }


}
