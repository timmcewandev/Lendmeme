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
    var imageInfo: [ImageInfo] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadInputViews()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! BorrowTableViewCell
        let memeImages = imageInfo[indexPath.row]
        cell.myImageView.contentMode = .left
        cell.myImageView.image = UIImage(data: memeImages.imageData!)

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
        return 150.0
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteItem = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [weak self] (action, indexPath) in
            let myphoto = self?.imageInfo[indexPath.row]
            guard let selectedImage = self?.imageInfo else { return }
            for selectedImage in selectedImage  {
                if selectedImage == myphoto {
                    let selectedImage = selectedImage
                    self?.dataController.viewContext.delete(selectedImage)
                    try? self?.dataController.viewContext.save()
                    self?.imageInfo.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .bottom)
                    self?.dataController.viewContext.refreshAllObjects()
                    self?.tableView.reloadData()
                }
            }
            
        })
        deleteItem.backgroundColor = UIColor.systemRed
        let markItemAsReturned = UITableViewRowAction(style: .default, title: "Mark item as returned", handler: { [weak self] (_ , indexPath)  in
            let myphoto = self?.imageInfo[indexPath.row]
            guard let selectImage = self?.imageInfo else { return }
            for selectedImage in selectImage {
                if selectedImage == myphoto {
                    let markImageAsReturned = selectedImage
                    markImageAsReturned.hasBeenReturned = true
                    try? self?.dataController.viewContext.save()
                    self?.dataController.viewContext.refreshAllObjects()
                    self?.tableView.reloadData()
                }
            }

        })
        if imageInfo[indexPath.row].hasBeenReturned == true {
            return [deleteItem]
        }
           markItemAsReturned.backgroundColor = UIColor.systemGreen
            return [deleteItem, markItemAsReturned]

     
     }
    
    fileprivate func DestroysCoreDataMaintence(_ result: [ImageInfo]) {
        for object in result {
            dataController.viewContext.delete(object)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhoto" {
            let destinationVC = segue.destination as! BorrowEditorViewController
            destinationVC.dataController = self.dataController
        }
    }
}
