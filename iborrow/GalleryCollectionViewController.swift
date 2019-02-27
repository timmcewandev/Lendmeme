//
//  MemeCollectionViewController.swift
//  meme 2.0
//
//  Created by sudo on 1/21/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
class GalleryCollectionViewController: UICollectionViewController {
    var member: UIImage?
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var imageSite: UIImageView!
    var memedImages: [BorrowInfo]! {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        return appDelegate.borrowInfo
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.collectionView?.reloadData()
        tabBarHidden()
        UIApplication.shared.isStatusBarHidden = true
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memedImages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        // Configure the cell...
        let memeImages = self.memedImages[indexPath.row]
        let imageview:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        imageview.contentMode = UIViewContentMode.scaleAspectFit
        let image = memeImages.memedImage
        imageview.image = image
        cell.contentView.addSubview(imageview)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let memedImages = self.memedImages[indexPath.row]
        member = memedImages.memedImage
        performSegue(withIdentifier: "toFourth", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFourth" {
            let HelloAll = segue.destination as! BorrowDetailViewController
            HelloAll.imageRevieved = member
        }
    }
    


    
    
    func tabBarHidden() {
        self.tabBarController!.tabBar.isHidden = false
    }
}
