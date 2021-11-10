//
//  BorrowTableViewCell.swift
//  Lendmeme
//
//  Created by Tim on 9/14/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit

protocol passBackRowAndDateable {
    func getRowAndDate(date: Date, row: Int)
}

class BorrowTableViewCell: UITableViewCell, getDateForReminderDelegate {
    func getDate(date: Date) {
        let dateformater = DateFormatter()
        dateformater.locale = Locale(identifier: "en_US_POSIX")
        dateformater.dateFormat = Constants.DateText.dateAndTime
        self.titleItemLabel.text = dateformater.string(from: date)
        guard let row = self.indexPath?.row else { return }
        self.delegate?.getRowAndDate(date: date, row: row)
        
    }
    
    @IBOutlet weak var borrowedDateLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleItemLabel: UILabel!
    @IBOutlet weak var nameOfBorrower: UILabel!
    @IBOutlet weak var reminderDate: UILabel!
    @IBOutlet weak var reminderDateIcon: UIImageView!
    @IBOutlet weak var returnedIcon: UIImageView!
    @IBOutlet weak var cover1: UIView!
    @IBOutlet weak var calendarTextField: UITextField!
    @IBOutlet weak var scheduleBTN: UIButton!
    
    
    
    var delegate: passBackRowAndDateable?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    @IBAction func calendarButtonPressed(_ sender: UIButton) {
        guard let controller = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as? DatePickerViewController else { return }
        controller.delegate = self
        if let sheet = controller.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        self.window?.rootViewController?.present(controller, animated: true, completion: nil)
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
