//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import UIKit

import FittedSheets
import CoreData
import MessageUI
import GoogleMobileAds

class BorrowTableViewController: UIViewController, UISearchBarDelegate, MFMessageComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var segmentOut: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    // MARK: - Variables
    var dataController:DataController!
    var member: UIImage?
    var imageInfo: [ImageInfo] = []
    var filteredData: [ImageInfo] = []
    var remindMe: [ImageInfo] = []
    @IBOutlet weak var searchBar: UISearchBar!
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var newData: [ImageInfo] = []
        newData = searchText.isEmpty ? filteredData : filteredData.filter { $0.titleinfo!.lowercased().contains(searchText.lowercased()) }
        if newData.isEmpty == true || searchText == "" {
            imageInfo = filteredData
        } else {
            imageInfo = newData
        }
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        imageInfo = filteredData
        searchBar.resignFirstResponder()
        
        tableView.reloadData()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadInputViews()
        searchBar.delegate = self
        bannerView.adUnitID = "ca-app-pub-6335247657896931/7400741709"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            imageInfo = result
            filteredData = imageInfo
            tableView.isHidden = false
        }
        self.segmentOut.selectedSegmentIndex = 0
        self.segmentOut.reloadInputViews()
        if imageInfo.count == 0 && self.segmentOut.selectedSegmentIndex == 0   {
            performSegue(withIdentifier: "starter", sender: self)
        }
        self.navigationController?.isNavigationBarHidden = false
//        self.segmentOut.didMoveToWindow()
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! BorrowTableViewCell
        let memeImages = imageInfo[indexPath.row]
        
        let date : Date = memeImages.creationDate!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let todaysDate = dateFormatter.string(from: date)
        cell.myDateLabel.text = todaysDate
        cell.myImageView.contentMode = .scaleAspectFill
        cell.myImageView.image = UIImage(data: memeImages.imageData!)
        cell.accessoryType = .none
        cell.myDateLabel.backgroundColor = .systemTeal
        cell.dateToStatusLabel.text = "Date:"
        cell.titleItemLabel.text = memeImages.titleinfo
        cell.nameOfBorrower.text = memeImages.topInfo
        if imageInfo[indexPath.row].hasBeenReturned == true {
            cell.dateToStatusLabel.text = "Status:"
            cell.myDateLabel.text = "Returned ✅"
            cell.myDateLabel.backgroundColor = .systemGreen
        }
        return cell
        
    }
    
    fileprivate func segmentControler(atSeg: Int, onReturn: Bool) {
        if self.segmentOut.selectedSegmentIndex == 0 {
            tableView.reloadData()
        } else {
            self.segmentOut.selectedSegmentIndex = atSeg
            if self.segmentOut.selectedSegmentIndex == atSeg {
                let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
                if let result = try? self.dataController.viewContext.fetch(fetchRequest){
                    var returnedTrue = [ImageInfo]()
                    for i in result {
                        if i.hasBeenReturned == onReturn {
                            returnedTrue.append(i)
                        }
                    }
                    self.imageInfo = returnedTrue
                    tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchBar.resignFirstResponder()
        let alert = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        let selectedImage = self.imageInfo[indexPath.row]
        let markImageAsReturned = selectedImage
        
        if markImageAsReturned.hasBeenReturned == false {
            alert.addAction(UIAlertAction(title: "Mark as returned", style: .default, handler: { _ in
                let selectedImage = self.imageInfo[indexPath.row]
                let markImageAsReturned = selectedImage
                markImageAsReturned.hasBeenReturned = true
                try? self.dataController.viewContext.save()
                tableView.cellForRow(at: indexPath)
                self.dataController.viewContext.refreshAllObjects()
                self.segmentControler(atSeg: 2, onReturn: false)

                self.segmentOut.reloadInputViews()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Mark as not returned", style: .default, handler: { _ in
                let selectedImage = self.imageInfo[indexPath.row]
                let markImageAsReturned = selectedImage
                markImageAsReturned.hasBeenReturned = false
                try? self.dataController.viewContext.save()
                tableView.cellForRow(at: indexPath)
                self.dataController.viewContext.refreshAllObjects()
                self.segmentControler(atSeg: 1, onReturn: true)
                    tableView.reloadData()
                self.segmentOut.reloadInputViews()
//                tableView.reloadData()
            }))
        }
        
        
        
        alert.addAction(UIAlertAction(title: "Remind me", style: .default, handler: { _ in
            let myphoto = [self.imageInfo[indexPath.row]]
            self.remindMe = myphoto
            self.performSegue(withIdentifier: "toSell", sender: self)
            
        }))
        
        //        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
        //            let myphoto = [self.imageInfo[indexPath.row]]
        //            self.remindMe = myphoto
        //            self.performSegue(withIdentifier: "toEdit", sender: self)
        //
        //        }))
        
        if imageInfo[indexPath.row].bottomInfo != "" {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Send Text message", comment: "Default action"), style: .default, handler: { _ in
                let composeVC = MFMessageComposeViewController()
                composeVC.messageComposeDelegate = self
                guard let number = self.imageInfo[indexPath.row].bottomInfo else {return}
                guard let image = self.imageInfo[indexPath.row].imageData else {return}
                if let first = self.imageInfo[indexPath.row].topInfo, let title = self.imageInfo[indexPath.row].titleinfo?.lowercased() {
                    composeVC.body = "Hello \(first) 👋, I was wondering if you are done with the \(title)? Is there a time you could return it? Thanks 👏"
                } else {
                    composeVC.body = "Hello 👋, I was wondering if you are done with this item? Is there a time you could return it? Thanks 👏"
                }
                composeVC.recipients = ["\(number)"]
                
                composeVC.addAttachmentData(image, typeIdentifier: "public.data", filename: "lendmeme.png")
                if MFMessageComposeViewController.canSendText() {
                    self.present(composeVC, animated: true, completion: nil)
                }
            }))
            
        }
        alert.addAction(UIAlertAction(title: "View image 🌁", style: .default, handler: { _ in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PVController") as! PVController
            controller.myImages = UIImage(data: self.imageInfo[indexPath.row].imageData!)
            let sheet = SheetViewController(controller: controller, sizes: [.fullScreen])
            self.present(sheet, animated: false, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let selectedImage = self.imageInfo[indexPath.row]
            
            self.dataController.viewContext.delete(selectedImage)
            try? self.dataController.viewContext.save()
            self.imageInfo.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            self.dataController.viewContext.refreshAllObjects()
            if self.imageInfo.count == 0 {
                self.performSegue(withIdentifier: "starter", sender: self)
            }
            self.tableView.reloadData()
        }))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func segmentControl(_ sender: Any) {
        if segmentOut.selectedSegmentIndex == 0 {
                    let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            if let result = try? dataController.viewContext.fetch(fetchRequest){
                imageInfo = result
                filteredData = imageInfo
                tableView.isHidden = false
            }
            tableView.reloadData()
        }
        if segmentOut.selectedSegmentIndex == 1 {
            let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            if let result = try? dataController.viewContext.fetch(fetchRequest){
                var returnedTrue = [ImageInfo]()
                for i in result {
                    if i.hasBeenReturned == true {
                        returnedTrue.append(i)
                    }
                }
                imageInfo = returnedTrue
                tableView.reloadData()
            }
        }
        
        if segmentOut.selectedSegmentIndex == 2 {
            let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            if let result = try? dataController.viewContext.fetch(fetchRequest){
                var returnedTrue = [ImageInfo]()
                for i in result {
                    if i.hasBeenReturned == false {
                        returnedTrue.append(i)
                    }
                }
                imageInfo = returnedTrue
                tableView.reloadData()
            }
        }
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteItem = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [weak self] (action, indexPath) in
            let myphoto = self?.imageInfo[indexPath.row]
            guard let selectedImage = self?.imageInfo else { return }
            for selectedImage in selectedImage  {
                if selectedImage == myphoto {
                    let selectedImage = selectedImage
                    self?.dataController.viewContext.delete(selectedImage)
                    try? self?.dataController.viewContext.save()
                    self?.imageInfo.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .bottom)
                    self?.dataController.viewContext.refreshAllObjects()
                    if self?.imageInfo.isEmpty == true && self?.segmentOut.selectedSegmentIndex == 0 {
                        self?.performSegue(withIdentifier: "toPhoto", sender: self)
                    }
                    tableView.reloadData()
                }
            }
            
        })
        deleteItem.backgroundColor = UIColor.systemRed
        let markItemAsReturned = UITableViewRowAction(style: .default, title: "Mark item as returned", handler: { [weak self] (_ , indexPath)  in
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! BorrowTableViewCell
            let myphoto = self?.imageInfo[indexPath.row]
            guard let selectImage = self?.imageInfo else { return }
            for selectedImage in selectImage {
                if selectedImage == myphoto {
                    let markImageAsReturned = selectedImage
                    markImageAsReturned.hasBeenReturned = true
                    try? self?.dataController.viewContext.save()
                    tableView.cellForRow(at: indexPath)
                    self?.dataController.viewContext.refreshAllObjects()
                    cell.myDateLabel.backgroundColor = .systemGreen
                    self?.segmentControler(atSeg: 2, onReturn: false)
                    self?.segmentOut.reloadInputViews()
                }
            }
            
        })
        let markItemAsNotReturned = UITableViewRowAction(style: .default, title: "Mark item as not returned", handler: { [weak self] (_ , indexPath)  in
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! BorrowTableViewCell
            let myphoto = self?.imageInfo[indexPath.row]
            guard let selectImage = self?.imageInfo else { return }
            for selectedImage in selectImage {
                if selectedImage == myphoto {
                    let markImageAsReturned = selectedImage
                    markImageAsReturned.hasBeenReturned = false
                    try? self?.dataController.viewContext.save()
                    tableView.cellForRow(at: indexPath)
                    self?.dataController.viewContext.refreshAllObjects()
                    self?.segmentControler(atSeg: 1, onReturn: true)
                    self?.segmentOut.reloadInputViews()
                }
            }
            
        })
        if imageInfo[indexPath.row].hasBeenReturned == true {
            markItemAsNotReturned.backgroundColor = .systemTeal
            return [deleteItem, markItemAsNotReturned]
        }
        markItemAsReturned.backgroundColor = UIColor.systemGreen
        return [deleteItem, markItemAsReturned]
    }
    
    fileprivate func DestroysCoreDataMaintence(_ result: [ImageInfo]) {
        for object in result {
            dataController.viewContext.delete(object)
        }
        
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "starter" {
            let destinvationVC = segue.destination as! BorrowEditorViewController
            destinvationVC.dataController = self.dataController
        }
        if segue.identifier == "toPhoto" {
            let destinationVC = segue.destination as! BorrowEditorViewController
            destinationVC.dataController = self.dataController
        }
        if segue.identifier == "toSell" {
            let destinationVC = segue.destination as! ImageViewController
            //            destinationVC.dataController = self.dataController
            destinationVC.receivedItem = remindMe
        }
        
        //        if segue.identifier == "toEdit" {
        //            let destinationVC = segue.destination as! BorrowUpdateViewController
        //            destinationVC.dataController = self.dataController
        //            destinationVC.receivedItem = remindMe
        //        }
        
        
    }
}

extension BorrowTableViewController: GADBannerViewDelegate {
    private func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Recieved ad")
    }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
