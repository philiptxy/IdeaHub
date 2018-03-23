//
//  ExploreViewController.swift
//  IdeaHub
//
//  Created by Philip Teow on 22/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ExploreViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = 124
            tableView.separatorStyle = .none
        }
    }
    
    
    //-------------------- Global Variables -----------------------
    
    var ref : DatabaseReference!
    var ideas : [Idea] = []
    
    
    //---------------------- viewDidLoad -------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        //    collectionView.register(IdeaFeedCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        loadIdeas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func loadIdeas() {
        let currentUserID = functions().getCurrentUserID()
        
        ref.child("ideas").queryOrdered(byChild: "timeStamp").observe(.childAdded) { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else {return}
            let anIdea = Idea(ideaID: snapshot.key, dict: dict)
            
            DispatchQueue.main.async {
                if anIdea.posterID != currentUserID {
                    self.ideas.append(anIdea)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    
}

extension ExploreViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("IdeaTableViewCell", owner: nil, options: nil)?.first as? IdeaTableViewCell else {return UITableViewCell()}
        
        cell.selectionStyle = .none
        
        let currentIdea = ideas[indexPath.row]
        
        //FORMATTING date
        let formatterFrom = DateFormatter()
        formatterFrom.dateFormat = "yyyyMMddHHmmss"
        
        let time = String(currentIdea.timeStamp)
        guard let dateFrom = formatterFrom.date(from: time) else {return UITableViewCell()}
        
        let formatterTo = DateFormatter()
        formatterTo.dateFormat = "dd MMMM yyyy HH:mm a"
        let date = formatterTo.string(from: dateFrom)
        
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.borderWidth = 2
        
        
        
        ref.child("users").child(currentIdea.posterID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String : Any] else {return}
            let currentUser = User(userID: snapshot.key, dict: dict)
            let userName = "\(currentUser.firstName) \(currentUser.lastName)"
            
            // PROVIDING value
            cell.titleLabel.text = currentIdea.name
            cell.dateLabel.text = date
            cell.nameLabel.text = userName
            cell.progressLabel.text = currentIdea.progress
            
            
        })
        
        return cell
    }
}

extension ExploreViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedIdea = ideas[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        vc.selectedIdea = selectedIdea
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

