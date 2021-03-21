//
//  ImageViewController.swift
//  Copyright © 2019 McEwanTech. All rights reserved.
//

import UIKit
import Foundation

//protocol getDateForReminderDelegate {
//    func getDate(date: Date, imageInformation: IndexPath)
//}

class ImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UNUserNotificationCenterDelegate  {
    // MARK: - Variables
    var selectedDate = Date()
    var receivedItem: [ImageInfo] = []
//    var delegate: getDateForReminderDelegate?
    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let todaysDate = Date()
        datePicker.minimumDate = todaysDate
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    @IBAction func datePickerDidSelectDate(_ sender: UIDatePicker) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = DateFormatter.Style.medium
            dateformatter.timeStyle = DateFormatter.Style.short
            let strDate = dateformatter.string(from: self.datePicker.date)
            let alert = UIAlertController(title: Constants.NameConstants.selectedDate, message: "\(strDate)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Constants.CommandListText.cancel, style: .cancel, handler: nil))
            
            
//            alert.addAction(UIAlertAction(title: Constants.CommandListText.remindMe, style: .default, handler: { (UIAlertAction) in
//                let selectedDate = sender.date
//                let imageInfo = self.receivedItem[0]
//                self.delegate?.getDate(date: selectedDate, imageInformation: imageInfo)
//

//            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}
