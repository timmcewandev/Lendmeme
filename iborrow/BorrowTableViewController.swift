//
//  MemeTableViewController.swift
//  meme 2.0
//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import UIKit

import FittedSheets
import CoreData

class BorrowTableViewController: UITableViewController {
    var dataController:DataController!
    var imageInfo: [ImageInfo] = []
    var member: UIImage?
//    var borrowInformation: [BorrowInfo]! {
//        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
//        return appDelegate.borrowInfo
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            //                                    DestroysCoreDataMaintence(result)
            imageInfo = result
            for object in imageInfo {
                print("\(object.imageData)")
            }
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
//        let memeImages = self.realm.objects(Data.self)[indexPath.row]
//
//
//        let memeTopText = memeImages.topText
//        let memeBottomText = memeImages.bottomText
//
//        cell.textLabel?.text = "\(memeTopText)     \(memeBottomText)"
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let memedImages = self.borrowInformation[indexPath.row]
//        member = memedImages.borrowImage
//
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "OptionTableViewController") as! OptionTableViewController
//      controller.memberImage = self.borrowInformation[indexPath.row].borrowImage
//      controller.memberNumber = self.borrowInformation[indexPath.row].bottomString
      let sheet = SheetViewController(controller: controller, sizes: [.halfScreen])
      sheet.setSizes([.fixed(215)])
      sheet.adjustForBottomSafeArea = true
      self.present(sheet, animated: false, completion: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhoto" {
            let destinationVC = segue.destination as! BorrowEditorViewController
            destinationVC.dataController = self.dataController
        }
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
