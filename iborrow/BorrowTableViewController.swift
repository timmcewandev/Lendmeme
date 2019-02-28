//
//  MemeTableViewController.swift
//  meme 2.0
//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import UIKit
import MessageUI


class BorrowTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
  }

  
    
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
      if memedImages.bottomString == "Number" && memedImages.topString == "Name" { return }
      let composeVC = MFMessageComposeViewController()
      composeVC.messageComposeDelegate = self
      composeVC.recipients = ["\(memedImages.bottomString)"]
      composeVC.body = "Hello \(memedImages.topString) I was wondering if you are done with my item? Is there a time you could return it?"
      if MFMessageComposeViewController.canSendText() {
        self.present(composeVC, animated: true, completion: nil)
      } else {
        print("Can't send messages.")
      }

      
//        performSegue(withIdentifier: "toThird", sender: self)
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
