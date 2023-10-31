//
//  PVController.swift
//  Lendmeme
//
//  Created by Tim on 6/19/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit

final class PVController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
        imageControl.image = myImages
        self.imageControl.contentScaleFactor = 3
    }
}
