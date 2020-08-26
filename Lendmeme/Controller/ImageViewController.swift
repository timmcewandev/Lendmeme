//
//  ImageViewController.swift
//  Copyright © 2019 McEwanTech. All rights reserved.
//

import UIKit
import Foundation

class ImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UNUserNotificationCenterDelegate  {
    
    // MARK: - Variables
    var selectedDate = Date()
    var receivedItem: [ImageInfo] = []
    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var submit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let todaysDate = Date()
        datePicker.minimumDate = todaysDate
        print("\(receivedItem.count)")
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
            let alert = UIAlertController(title: "Selected Date", message: "\(strDate)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Remind me", style: .default, handler: { (UIAlertAction) in
                let selectedDate = sender.date
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.scheduleNotification(at: selectedDate, name: self.receivedItem[0].titleinfo?.lowercased() ?? "item")
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
}
