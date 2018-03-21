//
//  LogInViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 21/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LogInViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton! {
        didSet {
            logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)
            logInButton.layer.borderColor = UIColor.black.cgColor
            logInButton.layer.borderWidth = 1
        }
    }
    
    @objc func logInButtonTapped() {
        guard let email = loginTextField.text,
            let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let validError = error {
                self.showAlert(withTitle: "Error", message: validError.localizedDescription)
            }
            
            if user != nil {
                self.loginTextField.text = ""
                self.passwordTextField.text = ""
                
                let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
                
                guard let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else {return}
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    var ref : DatabaseReference!
    
    //------------------- viewDidLoad ------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        
        
        
    }
    
    
    
    
   

}
