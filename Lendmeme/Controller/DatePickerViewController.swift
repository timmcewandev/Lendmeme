//
//  DatePickerViewController.swift
//  Lendmeme
//
//  Created by Tim McEwan on 11/6/21.
//  Copyright © 2021 sudo. All rights reserved.
//

import UIKit
protocol getDateForReminderDelegate {
    func getDate(date: Date)
}
class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelBTN: UIButton!
    @IBOutlet weak var doneBTN: UIButton!
    
    var delegate: getDateForReminderDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DoneButton(_ sender: Any) {
        self.delegate?.getDate(date: datePicker.date)
        self.dismiss(animated: true, completion: nil)
//        self.calendarTextField.resignFirstResponder()
    }
    
}
