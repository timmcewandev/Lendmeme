//
//  BorrowTableViewCell.swift
//  Lendmeme
//
//  Created by Tim on 9/14/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit

protocol passBackRowAndDateable {
    func getRowAndDate(date: Date, row: Int, section: Int)
}

class BorrowTableViewCell: UITableViewCell, getDateForReminderDelegate {
    func getDate(date: Date) {
        let dateformater = DateFormatter()
        dateformater.locale = Locale(identifier: "en_US_POSIX")
        dateformater.dateFormat = Constants.DateText.dateAndTime
        guard let row = self.indexPath?.row else { return }
        guard let section = self.indexPath?.section else { return }
        self.delegate?.getRowAndDate(date: date, row: row, section: section)
        
    }
    
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet weak var cover1: UIView!
    @IBOutlet weak var titleText: UILabel!
    
   
    
    var delegate: passBackRowAndDateable?
    
    var imageCell: ImageInfo! {
        didSet {
            if let memeImageData = imageCell.imageData {
                myImageView.image = UIImage(data: memeImageData)
                myImageView.isOpaque = true
                titleText.text = imageCell.titleinfo
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isOpaque = true
        self.backgroundColor = UIColor.white
    }
    
    @IBAction func calendarButtonPressed(_ sender: UIButton) {
        self.window?.rootViewController?.view.endEditing(true)
        guard let controller = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as? DatePickerViewController else { return }
        controller.delegate = self
        if let sheet = controller.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        self.window?.rootViewController?.present(controller, animated: true, completion: nil)
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
