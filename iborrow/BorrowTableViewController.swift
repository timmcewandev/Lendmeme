//
//  MemeTableViewController.swift
//  meme 2.0
//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import UIKit

import FittedSheets
import RealmSwift

class BorrowTableViewController: UITableViewController {
    let realm = try! Realm()
  let data = Data()
    var member: UIImage?
    var borrowInformation: [BorrowInfo]! {
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
      print("\(String(describing: self.borrowInformation))")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.realm.objects(Data.self).count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        let memeImages = self.realm.objects(Data.self)[indexPath.row]


        let memeTopText = memeImages.topText
        let memeBottomText = memeImages.bottomText
        
        cell.textLabel?.text = "\(memeTopText)     \(memeBottomText)"
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memedImages = self.borrowInformation[indexPath.row]
        member = memedImages.borrowImage
      
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "OptionTableViewController") as! OptionTableViewController
      controller.memberImage = self.borrowInformation[indexPath.row].borrowImage
      controller.memberNumber = self.borrowInformation[indexPath.row].bottomString
      let sheet = SheetViewController(controller: controller, sizes: [.halfScreen])
      sheet.setSizes([.fixed(150)])
      sheet.adjustForBottomSafeArea = true
      self.present(sheet, animated: false, completion: nil)

    }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toFirst" {
      let vc = segue.destination as! OptionTableViewController
      vc.memberImage = member
    }
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
