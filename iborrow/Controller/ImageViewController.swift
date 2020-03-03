//
//  ImageViewController.swift
//  iborrow
//
//  Created by sudo on 3/1/19.
//  Copyright © 2019 sudo. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
  @IBOutlet weak var imageControl: UIImageView!
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
    }
}
