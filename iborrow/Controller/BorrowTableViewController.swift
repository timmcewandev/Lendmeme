//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import UIKit

import FittedSheets
import CoreData

class BorrowTableViewController: UITableViewController {
    
    // MARK: - Variables
    var dataController:DataController!
    var member: UIImage?
    var imageInfo: [ImageInfo] = [] {
        didSet {
//            print("The value of myProperty changed from \(oldValue) to \(imageInfo)")
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            imageInfo = result
        }
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageInfo.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let memeImages = imageInfo[indexPath.row]
        cell.imageView?.center = CGPoint(x: cell.contentView.bounds.size.width / 2, y: cell.contentView.bounds.size.height / 2)
        cell.imageView?.image = UIImage(data: memeImages.imageData!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "OptionTableViewController") as! OptionTableViewController
        controller.memberImage = self.imageInfo[indexPath.row].imageData
        controller.memberNumber = self.imageInfo[indexPath.row].bottomInfo
        let sheet = SheetViewController(controller: controller, sizes: [.halfScreen])
        sheet.setSizes([.fixed(215)])
        sheet.adjustForBottomSafeArea = true
        self.present(sheet, animated: false, completion: nil)
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.00
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            imageInfo.remove(at: indexPath.row)
            let commit = imageInfo[indexPath.row]
            dataController.viewContext.delete(commit)            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhoto" {
            let destinationVC = segue.destination as! BorrowEditorViewController
            destinationVC.dataController = self.dataController
        }
    }
}
//extension UITableView {
//    
//    func hideExcessCells() {
//        tableFooterView = UIView(frame: CGRect.zero)
//    }
//}
