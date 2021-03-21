//
//  BorrowTableViewCell.swift
//  Lendmeme
//
//  Created by Tim on 9/14/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit

protocol getDateForReminderDelegate {
    func getDate(date: Date, row: Int)
}
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
    @IBOutlet weak var calendarTextField: UITextField!
    
    var delegate: getDateForReminderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        calendarTextField.addInputViewDatePicker(target: self, selector: #selector(doneButtonPressed))
    }


    @objc func doneButtonPressed() {
        if let  datePicker = self.calendarTextField.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constants.DateText.dateAndTime
            self.calendarTextField.text = dateFormatter.string(from: datePicker.date)
            guard let row = self.indexPath?.row else { return }
            self.delegate?.getDate(date: datePicker.date, row: row)

//            print(" Here is the index path\(String(describing: self.indexPath?.row))")
        }
        self.calendarTextField.resignFirstResponder()
     }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.isHighlighted = true
            calendarTextField.resignFirstResponder()
        } else {
            self.isHighlighted = false
            print("not selected")
        }
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

extension UITextField {

  func addInputViewDatePicker(target: Any, selector: Selector) {
    
    let todaysDate = Date()
    let screenWidth = UIScreen.main.bounds.width
   //Add DatePicker as inputView
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 100))
    datePicker.datePickerMode = .dateAndTime
    datePicker.minimumDate = todaysDate
    self.inputView = datePicker

   //Add Tool Bar as input AccessoryView
   let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
   let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
   let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
   let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
   toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: false)

   self.inputAccessoryView = toolBar
}

  @objc func cancelPressed() {
    self.resignFirstResponder()
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
