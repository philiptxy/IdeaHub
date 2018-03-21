//
//  ViewControllerExtensions.swift
//  IdeaHub
//
//  Created by Philip Teow on 21/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    //Show alert for validation of signUp and signIn process
    func showAlert(withTitle title: String, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension UIViewController {
    func getImage(_ urlString: String, _ imageView: UIImageView) {
        guard let url = URL.init(string: urlString) else {return}
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let validError = error {
                print(validError.localizedDescription)
            }
            
            if let validData = data {
                let profileImage = UIImage(data: validData)
                
                DispatchQueue.main.async {
                    imageView.image = profileImage
                }
            }
        }
        task.resume()
    }
    
}
