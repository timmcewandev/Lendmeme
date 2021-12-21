//
//  PVController.swift
//  Lendmeme
//
//  Created by Tim on 6/19/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PVController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    @IBOutlet weak var imageControl: UIImageView!
    @IBOutlet weak var bannerView: GADBannerView!
    

    
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
        bannerView.adUnitID = "ca-app-pub-4726435113512089/1677733583" // real
//                bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //fake
                        bannerView.rootViewController = self
                bannerView.delegate = self
                        bannerView.load(GADRequest())
    }
}
