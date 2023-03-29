//
//  BorrowTableViewCell.swift
//  Lendmeme
//
//  Created by Tim on 9/14/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit

class BorrowTableViewCell: UITableViewCell {
    func getDate(date: Date) {
        let dateformater = DateFormatter()
        dateformater.locale = Locale(identifier: "en_US_POSIX")
        dateformater.dateFormat = Constants.DateText.dateAndTime
    }
    
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet weak var cover1: UIView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var borrowName: UILabel!
    @IBOutlet weak var dateView: UIView!
    
    var imageCell: ImageInfo! {
        didSet {
            if let memeImageData = imageCell.imageData {
                myImageView.image = UIImage(data: memeImageData)
                myImageView.isOpaque = true
                myImageView.layer.cornerRadius = 10
                titleText.text = " Reminder date: \(imageCell.selectedDate ?? "")"
                titleText.font = titleText.font.withSize(16)
                
                borrowName.text = imageCell.nameOfPersonBorrowing
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isOpaque = true
        self.backgroundColor = UIColor.white
    }
}
extension UIResponder {
    /**
     * Returns the next responder in the responder chain cast to the given type, or
     * if nil, recurses the chain until the next responder is nil or castable.
     */
    func next<U: UIResponder>(of type: U.Type = U.self) -> U? {
        return self.next.flatMap({ $0 as? U ?? $0.next() })
    }
    
}
extension UITableViewCell {
    var tableView: UITableView? {
        return self.next(of: UITableView.self)
    }

    var indexPath: IndexPath? {
        return self.tableView?.indexPath(for: self)
    }
}
