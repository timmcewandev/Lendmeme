//
//  ImageViewController.swift
//  Copyright © 2019 McEwanTech. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var submit: UIButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    var myImages: UIImage?
    
    @IBAction func datePickerAction(_ sender: Any) {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.medium
        let strDate = dateformatter.string(from: datePicker.date)
        selectedDateLabel.text = strDate
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        
    }

}
