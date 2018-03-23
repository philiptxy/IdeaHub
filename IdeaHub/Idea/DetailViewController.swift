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
    @IBOutlet weak var progressLabel: UILabel! {
        didSet {
            progressLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(labelTapped(sender:)))
            progressLabel.addGestureRecognizer(tap)
        }
    }
    
    @objc func progressLabelTapped() {
        
    }
    
    @IBOutlet weak var likeButton: UIButton! {
        didSet {
            likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func likeButtonTapped() {
        functions().action(type: .like, targetUid: selectedIdea.ideaID)
        ref.child("ideas").child(selectedIdea.ideaID).child("likeby").observe(.value) { (snapshot) in
            let numOfLikes = snapshot.childrenCount
            self.numberOfLikesLabel.text = "\(numOfLikes) likes"
        }
    }
    @IBOutlet weak var dislikeButton: UIButton! {
        didSet {
            dislikeButton.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
            
            
            
        }
    }
    
    @objc func dislikeButtonTapped() {
        functions().action(type: .dislike, targetUid: selectedIdea.ideaID)
        ref.child("ideas").child(selectedIdea.ideaID).child("dislikeby").observe(.value) { (snapshot) in
            let dislikes = snapshot.childrenCount
            self.numberOfDislikesLabel.text = "\(dislikes) dislikes"
        }
    }
    
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    
    @IBOutlet weak var numberOfDislikesLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel! {
        didSet {
            commentLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(commentLabelTapped))
            commentLabel.addGestureRecognizer(tap)
        }
    }
    
    @objc func commentLabelTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as? CommentViewController else {return}
        vc.selectedIdea = selectedIdea
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func viewLocationTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ViewLocationViewController") as? ViewLocationViewController else {return}
        vc.selectedIdea = selectedIdea
        navigationController?.pushViewController(vc, animated: true)
    }
    //------------------------ Global Variable ----------------------
    
    var ref : DatabaseReference!
    
    var selectedIdea : Idea = Idea()
    
    var selectedPicker : String = ""
    var options = ["Not Started", "In Progess", "Incomplete", "Complete"]
    var didSelect : Bool = false
    
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
        
        self.getImage(self.selectedIdea.postedPicURL, self.postedPicImageView)
        ref.child("users").child(selectedIdea.posterID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else {return}
            let poster = User(userID: snapshot.key, dict: dict)
            
            DispatchQueue.main.async {
                self.titleLabel.text = self.selectedIdea.name
                
                self.descriptionLabel.text = self.selectedIdea.description
                self.getImage(poster.profilePicURL, self.profilePicImageView)
                self.nameLabel.text = "\(poster.firstName) \(poster.lastName)"
                self.dateLabel.text = date
                self.progressLabel.text = self.selectedIdea.progress
                //TODO: number of likes
            }
            
            
            
            
        }
        
        
        ref.child("ideas").child(selectedIdea.ideaID).child("likeby").observe(.value) { (snapshot) in
            let numOfLikes = snapshot.childrenCount
            self.numberOfLikesLabel.text = "\(numOfLikes) likes"
        }
        ref.child("ideas").child(selectedIdea.ideaID).child("dislikeby").observe(.value) { (snapshot) in
            let dislikes = snapshot.childrenCount
            self.numberOfDislikesLabel.text = "\(dislikes) dislikes"
            
        }
    }
    
    
}

extension DetailViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    @objc func labelTapped(sender: UITapGestureRecognizer) {
        
        
        
        
        didSelect = false
        
        let title = ""
        let message = "\n\n\n\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.isModalInPopover = true
        
        
        
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame: CGRect = CGRect(x: 17, y: 52, width: view.frame.width*0.83, height: view.frame.height*0.2) // CGRectMake(left), top, width, height) - left and top are like margins
        let picker: UIPickerView = UIPickerView(frame: pickerFrame)
        
        /* If there will be 2 or 3 pickers on this view, I am going to use the tag as a way
         to identify them in the delegate and datasource.  This part with the tags is not required.
         I am doing it this way, because I have a variable, witch knows where the Alert has been invoked from.*/
        
        
        //set the pickers datasource and delegate
        picker.delegate = self
        picker.dataSource = self
        
        //Add the picker to the alert controller
        alert.view.addSubview(picker);
        
        //Create the toolbar view - the view witch will hold our 2 buttons
        let toolFrame = CGRect(x: 17, y: 5, width: 270, height: 45)
        let toolView: UIView = UIView(frame: toolFrame);
        
        //add buttons to the view
        let buttonCancelFrame: CGRect = CGRect(x: 0, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView
        
        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", for: UIControlState.normal)
        buttonCancel.setTitleColor(UIColor.blue, for: UIControlState.normal)
        toolView.addSubview(buttonCancel); //add it to the toolView
        
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(cancelSelection(sender:)), for: .touchUpInside)
        
        
        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: toolView.frame.width-100+10, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", for: UIControlState.normal)
        buttonOk.setTitleColor(UIColor.blue, for: UIControlState.normal)
        toolView.addSubview(buttonOk); //add to the subview
        
        //Add the tartget. In my case I dynamicly set the target of the select button
        
        buttonOk.addTarget(self, action: #selector(selectThis(sender:)), for: .touchUpInside)
        
        
        //add the toolbar to the alert controller
        alert.view.addSubview(toolView);
        
        self.present(alert, animated: true, completion: nil);
    }
    
    @objc func selectThis(sender: UIButton){
        // Your code when select button is tapped
        print("select")
        self.dismiss(animated: true, completion: nil)
        
        progressLabel.text = String(selectedPicker)
        
        if didSelect == false {
            progressLabel.text = String(options[0])
        }
        
        guard let progress = progressLabel.text else {return}
        ref.child("ideas").child(selectedIdea.ideaID).updateChildValues(["progress" : progress])
        
        //ref.child("users").child(selectedIdea.posterID).c
        
        //TODO: edit in users
        
    }
    
    
    @objc func cancelSelection(sender: UIButton){
        print("Cancel")
        self.dismiss(animated: true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns number of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return self.options.count
        
    }
    
    // Return the title of each row in your picker ... In my case that will be the profile name or the username string
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
        
        
    }
    
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelect = true
        
        
        self.selectedPicker = options[row]
        
        
    }
    
}
