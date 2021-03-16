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
    @IBOutlet weak var returnedIcon: UIImageView!
    @IBOutlet weak var cover1: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //        myImageView.layer.borderWidth = 1
        //        myImageView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func returnedAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
            self.returnedIcon.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.returnedIcon.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                self.returnedIcon.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: {(_ finished: Bool) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {() -> Void in
                    self.returnedIcon.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.returnedIcon.alpha = 1.0
                }, completion: {(_ finished: Bool) -> Void in
                    self.returnedIcon.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            })
        })
    }
    
}
