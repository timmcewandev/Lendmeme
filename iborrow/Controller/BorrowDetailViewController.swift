//
//  DetailViewController.swift
//  meme 2.0
//
//  Created by sudo on 1/28/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit

class BorrowDetailViewController: UIViewController {
    var imageRevieved: UIImage?
    @IBOutlet weak var imageNOw: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let defusedBox = imageRevieved {
            imageNOw.image = defusedBox
        }
    }
}
