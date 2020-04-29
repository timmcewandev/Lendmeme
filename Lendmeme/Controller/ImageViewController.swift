//
//  ImageViewController.swift
//  Copyright © 2019 McEwanTech. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet weak var imageControl: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    var myImages: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageControl.image = myImages
        self.imageControl.contentScaleFactor = 3
    }
    
    @IBAction func datePickerAction(_ sender: Any) {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        let strDate = dateformatter.string(from: datePicker.date)
        print("\(strDate)")
    }
    
}
