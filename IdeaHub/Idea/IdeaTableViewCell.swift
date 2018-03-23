//
//  IdeaTableViewCell.swift
//  IdeaHub
//
//  Created by Philip Teow on 23/03/2018.
//  Copyright © 2018 Philip Teow. All rights reserved.
//

import UIKit

class IdeaTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
