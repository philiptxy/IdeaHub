//
//  PostViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 22/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PostViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var editTitleImageView: UIImageView! {
        didSet {
            editTitleImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(editTitleImageViewTapped))
            editTitleImageView.addGestureRecognizer(tap)
        }
    }
    @objc func editTitleImageViewTapped() {
        titleLabel.isHidden = true
        editTitleImageView.isHidden = true
        titleTextField.isHidden = false
        cancelTitleButton.isHidden = false
        doneTitleButton.isHidden = false
        
        titleTextField.text = titleLabel.text
    }
    
    @IBOutlet weak var cancelTitleButton: UIButton! {
        didSet {
            cancelTitleButton.addTarget(self, action: #selector(cancelTitleButtonTapped), for: .touchUpInside)
        }
    }
    @objc func cancelTitleButtonTapped() {
        titleLabel.isHidden = false
        editTitleImageView.isHidden = false
        titleTextField.isHidden = true
        cancelTitleButton.isHidden = true
        doneTitleButton.isHidden = true
    }
    
    @IBOutlet weak var doneTitleButton: UIButton! {
        didSet {
            doneTitleButton.addTarget(self, action: #selector(doneTitleButtonTapped), for: .touchUpInside)
        }
    }
    @objc func doneTitleButtonTapped() {
        titleLabel.isHidden = false
        editTitleImageView.isHidden = false
        titleTextField.isHidden = true
        cancelTitleButton.isHidden = true
        doneTitleButton.isHidden = true
        
        guard let newTitle = titleTextField.text else {return}
        titleLabel.text = newTitle
    }
    @IBOutlet weak var postImageView: UIImageView! {
        didSet {
            postImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(postImageViewTapped))
            postImageView.addGestureRecognizer(tap)
        }
    }
    @objc func postImageViewTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var locationImageView: UIImageView! {
        didSet {
            locationImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(locationImageViewTapped))
            locationImageView.addGestureRecognizer(tap)
        }
    }
    
    @objc func locationImageViewTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBOutlet weak var locationLabel: UILabel! {
        didSet {
            locationLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(locationLabelTapped))
            locationLabel.addGestureRecognizer(tap)
        }
    }
    
    @objc func locationLabelTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var descTextView: UITextView!
    
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func postButtonTapped() {
        guard let name = titleLabel.text,
            let description = descTextView.text,
            let location = locationLabel.text else {return}
        
        if let image = self.postImageView.image {
            self.uploadToStorage(image)
        }
        
        let currentTimeDatabase = getCurrentTimeDatabase()
        let currentUserID = functions().getCurrentUserID()
        
        let newIdea : [String : Any] = ["name" : name, "description" : description, "lat" : lat, "long" : long, "locationName" : location, "posterID" : currentUserID, "progress" : "Not Started", "timeStamp" : currentTimeDatabase]
        
        let path = ref.child("ideas").childByAutoId()
        
        self.ref.child("ideas").child(path.key).setValue(newIdea)
        
        ref.child("users").child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else {return}
            let currentUser = User(userID: snapshot.key, dict: dict)
            let num = currentUser.numOfUnstarted + 1
            self.ref.child("users").child(currentUserID).updateChildValues(["numOfUnstarted" : num])
        }
        
        
        
        ideaID = path.key
        
        //RESET outlets
        titleLabel.text = "New Idea"
        locationLabel.text = "Add Location"
        descTextView.text = "Insert description here"
        postImageView.contentMode = .scaleAspectFit
        postImageView.image = UIImage(named: "addPhoto")
        
        
        showAlertMsg(withTitle: "Success!", message: "Your idea has been posted!", time: 1)
        
        
    }
    
    //------------------- Global Variables -----------------------
    
    var ref : DatabaseReference!
    
    var lat : Double = 0
    var long : Double = 0
    var locationName : String = "Add Location"
    var ideaID : String = ""
    
    //------------------- viewDidLoad ---------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationLabel.text = locationName
    }
    
    
    func uploadToStorage(_ image: UIImage) {
        let storageRef = Storage.storage().reference()
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let currentUserID = functions().getCurrentUserID()
        
        
        
        storageRef.child(currentUserID).child(ideaID).putData(imageData, metadata: metaData) { (meta, error) in
            
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadURL = meta?.downloadURL()?.absoluteString {
                self.ref.child("ideas").child(self.ideaID).child("postedPicURL").setValue(downloadURL)
            }
        }
    }
    
    
    



//-------------------------- Show alert with timer --------------------------
    var alertController: UIAlertController?
    var alertTimer: Timer?
    var remainingTime = 0
    
    func showAlertMsg(withTitle title: String, message: String?, time: Int) {
        
        guard (self.alertController == nil) else {
            print("Alert already displayed")
            return
        }
        
        self.remainingTime = time
        
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        self.alertTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        
        self.present(self.alertController!, animated: true, completion: nil)
    }
    
    @objc func countDown() {
        self.remainingTime -= 1
        if (self.remainingTime < 0) {
            self.alertTimer?.invalidate()
            self.alertTimer = nil
            self.alertController!.dismiss(animated: true, completion: {
                self.alertController = nil
            })
        }
        
    }

}


//-------------------------- ImagePicker ------------------------------
extension PostViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        postImageView.contentMode = .scaleAspectFill
        postImageView.image = image
        
    }
    
}

extension PostViewController {
    
    func getCurrentTimePrint() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm a"
        let currentDateString = formatter.string(from: Date())
        return currentDateString
    }
    
    func getCurrentTimeDatabase() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyMMddHHmmss"
        let currentDateString = formatter.string(from: Date())
        guard let currentDateInt = Int(currentDateString) else {
            return 0
        }
        return currentDateInt
    }
}
