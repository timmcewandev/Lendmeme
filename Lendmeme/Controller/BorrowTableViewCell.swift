//
//  BorrowTableViewCell.swift
//  iborrow
//
//  Created by Tim on 3/18/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit

class BorrowTableViewCell: UITableViewCell {

    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        myDateLabel.layer.cornerRadius = 8.5
        myDateLabel.clipsToBounds = true
        myDateLabel.layer.borderWidth = 0.5
        myDateLabel.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
