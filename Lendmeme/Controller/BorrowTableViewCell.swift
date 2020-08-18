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
    @IBOutlet weak var dateToStatusLabel: UILabel!
    @IBOutlet weak var titleItemLabel: UILabel!
    @IBOutlet weak var nameOfBorrower: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        myImageView.layer.borderWidth = 1
        myImageView.layer.borderColor = UIColor.black.cgColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
