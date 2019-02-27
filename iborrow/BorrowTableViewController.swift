//
//  MemeTableViewController.swift
//  meme 2.0
//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import Foundation
import UIKit


class BorrowTableViewController: UITableViewController {
    
    var member: UIImage?
    var memedImages: [BorrowInfo]! {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        return appDelegate.borrowInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
        hideTabBar()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memedImages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let memeImages = self.memedImages[indexPath.row]
        
        cell.imageView?.image = memeImages.memedImage
        let memeTopText = memeImages.topString
        let memeBottomText = memeImages.bottomString
        
        cell.textLabel?.text = "\(memeTopText)     \(memeBottomText)"
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memedImages = self.memedImages[indexPath.row]
        member = memedImages.memedImage
        performSegue(withIdentifier: "toThird", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toThird" {
            let destinationVC = segue.destination as! BorrowDetailViewController
            destinationVC.imageRevieved = member
        }
    }
    func hideTabBar() {
        self.tabBarController!.tabBar.isHidden = false
    }
    
    @IBAction func plusBTN(_ sender: Any) {
        let verifyVC = self.storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! BorrowEditorViewController
        verifyVC.modalPresentationStyle = .overCurrentContext
        present(verifyVC, animated: true, completion: nil)
    }
    
    
    
}
extension UITableView {
    
    func reloadOnMainThread() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    func hideExcessCells() {
        tableFooterView = UIView(frame: CGRect.zero)
    }
}
