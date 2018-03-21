//
//  SignUpViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 21/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
            imageView.addGestureRecognizer(tap)
        }
    }
    
    @objc func imageViewTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
            signUpButton.layer.borderColor = UIColor.black.cgColor
            signUpButton.layer.borderWidth = 1
        }
    }
    
    @objc func signUpButtonTapped() {
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text else {return}
        
        //Input Validation
        if !email.contains("@") {
            showAlert(withTitle: "Invalid Email Format", message: "Please input a valid email")
        } else if firstName.count < 1 {
            showAlert(withTitle: "Invalid First Name", message: "Please Enter Your First Name")
        } else if lastName.count < 1 {
            showAlert(withTitle: "Invalid Last Name", message: "Please Enter Your Last Name")
        } else if password.count < 4 {
            showAlert(withTitle: "Invalid Password", message: "Password must be at least 4 characters long")
        } else {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                
                //Error
                if let validError = error {
                    self.showAlert(withTitle: "ERROR", message: validError.localizedDescription)
                }
                
                
                //Successful Creation of New User
                if let validUser = user {
                    
                    if let image = self.imageView.image {
                        self.uploadToStorage(image)
                    }
                    
                    let newUser : [String : Any] = ["email" : email, "firstName" : firstName, "lastName" : lastName]
                    
                    self.ref.child("users").child(validUser.uid).setValue(newUser)
                    
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    
                    guard let tabC = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else {return}
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    self.present(tabC, animated: false, completion: nil)
                }
            })
        }
    }
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        
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
                self.ref.child("users").child(uid).child("profilePicUrl").setValue(downloadURL)
            }
        }
    }

}

extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        
        imageView.image = image
        
    }
    
}
