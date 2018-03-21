//
//  ViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 21/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton! {
        didSet {
            logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)
            logInButton.layer.borderColor = UIColor.black.cgColor
            logInButton.layer.borderWidth = 1
        }
    }
    
    @objc func logInButtonTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var signUpButton: UIButton! {
        didSet {
            signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
            signUpButton.layer.borderColor = UIColor.black.cgColor
            signUpButton.layer.borderWidth = 1
        }
    }
    
    @objc func signUpButtonTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //------------------- viewDidLoad ------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        if Auth.auth().currentUser != nil {
            let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController else {return}
            
            present(vc, animated: true, completion: nil)
            
        }
    }
    
    
    
    
  

}

