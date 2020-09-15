//
//  BorrowTableViewCell.swift
//  Lendmeme
//
//  Created by Tim on 9/14/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit

class BorrowTableViewCell: UITableViewCell {

    @IBOutlet weak var borrowedDateLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleItemLabel: UILabel!
    @IBOutlet weak var nameOfBorrower: UILabel!
    @IBOutlet weak var reminderDate: UILabel!
    @IBOutlet weak var reminderDateIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        myImageView.layer.borderWidth = 1
//        myImageView.layer.borderColor = UIColor.black.cgColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
