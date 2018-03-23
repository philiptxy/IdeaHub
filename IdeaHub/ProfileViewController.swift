//
//  ProfileViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 22/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBAction func logOutTapped(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            
        }
    }
    
    @IBAction func editPicTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var lastNameLabel: UILabel!
    
    @IBOutlet weak var numOfUnstartedLabel: UILabel!
    
    @IBOutlet weak var numOfInProgressLabel: UILabel!
    
    @IBOutlet weak var numOfIncompleteLabel: UILabel!
    
    @IBOutlet weak var numOfCompleteLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func editButtonTapped() {
        nameLabel.isHidden = true
        lastNameLabel.isHidden = true
        editButton.isHidden = true
        nameTextField.isHidden = false
        lastNameTextField.isHidden = false
        cancelButton.isHidden = false
        doneButton.isHidden = false
        
        nameTextField.text = nameLabel.text
        lastNameTextField.text = lastNameLabel.text
        
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        }
    }
    @objc func cancelButtonTapped() {
        nameLabel.isHidden = false
        lastNameLabel.isHidden = false
        editButton.isHidden = false
        nameTextField.isHidden = true
        lastNameTextField.isHidden = true
        cancelButton.isHidden = true
        doneButton.isHidden = true
    }
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func doneButtonTapped() {
        nameLabel.isHidden = false
        lastNameLabel.isHidden = false
        editButton.isHidden = false
        nameTextField.isHidden = true
        lastNameTextField.isHidden = true
        cancelButton.isHidden = true
        doneButton.isHidden = true
        
        nameLabel.text = nameTextField.text
        lastNameLabel.text = lastNameTextField.text
        
       // guard let newName = nameTextField.text else {return}
        
        let currentUserID = functions().getCurrentUserID()
        
        ref.child("users").child(currentUserID).updateChildValues(["firstName" : nameTextField.text ?? "", "lastName" : lastNameTextField.text ?? ""])
    }
    
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        loadInfo()
    }

    func loadInfo() {
        
        let currentUserID = functions().getCurrentUserID()
        
        ref.child("users").child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else {return}
            let currentUser = User(userID: snapshot.key, dict: dict)
            DispatchQueue.main.async {
                self.nameLabel.text = currentUser.firstName
                self.lastNameLabel.text = currentUser.lastName
                self.getImage(currentUser.profilePicURL, self.profileImageView)
                self.numOfUnstartedLabel.text = "Number of unstarted ideas: \(currentUser.numOfUnstarted)"
                self.numOfInProgressLabel.text = "Number of ideas in progress: \(currentUser.numOfInProgress)"
                self.numOfIncompleteLabel.text = "Number of incomplete ideas: \(currentUser.numOfIncomplete)"
                self.numOfCompleteLabel.text = "Number of complete ideas: \(currentUser.numOfComplete)"
            }
        }
    }
    
    
    func uploadToStorage(_ image: UIImage) {
        let storageRef = Storage.storage().reference()
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        storageRef.child(uid).child("profilePic").putData(imageData, metadata: metaData) { (meta, error) in
            
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let downloadURL = meta?.downloadURL()?.absoluteString {
                self.ref.child("users").child(uid).child("profilePicURL").setValue(downloadURL)
            }
        }
    }


}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        profileImageView.image = image
        uploadToStorage(image)
    }
    
}
