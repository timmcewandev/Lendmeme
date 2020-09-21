//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import UIKit

import FittedSheets
import CoreData
import MessageUI
//import GoogleMobileAds

class BorrowTableViewController: UIViewController, getDateForReminderDelegate, MFMessageComposeViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var segmentOut: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    //    @IBOutlet weak var bannerView: GADBannerView!
    
    // MARK: - Properties
    let toStarterViewController = "starter"
    let toEditorViewController = "toPhoto"
    let toCalendarViewController = "toCalendar"
    let borrowTableViewCell = "BorrowTableViewCell"
    let creationDate = "creationDate"
    var hasBeenSeen = false
    var dataController:DataController!
    var imageInfo: [ImageInfo] = []
    var filteredData: [ImageInfo] = []
    var remindMe: [ImageInfo] = []
    var reminderDate: Date?
    
    func getDate(date: Date, imageInformation: ImageInfo) {
        for imageInfo in self.imageInfo {
            if imageInfo == imageInformation {
                imageInfo.reminderDate = date
                try? self.dataController.viewContext.save()
            }
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadInputViews()
        searchBar.delegate = self
        let nib = UINib(nibName: borrowTableViewCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: borrowTableViewCell)
        //        bannerView.adUnitID = "ca-app-pub-6335247657896931/7400741709"
        //        bannerView.rootViewController = self
        //        bannerView.load(GADRequest())
        //        bannerView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: creationDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            imageInfo = result
            filteredData = imageInfo
            tableView.isHidden = false
        }
        self.segmentOut.selectedSegmentIndex = 0
        self.segmentOut.reloadInputViews()
        if imageInfo.count == 0 && self.segmentOut.selectedSegmentIndex == 0   {
            performSegue(withIdentifier: self.toStarterViewController, sender: self)
        }
        self.navigationController?.isNavigationBarHidden = false
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func segmentControl(_ sender: Any) {
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: creationDate, ascending: false)
        switch segmentOut.selectedSegmentIndex {
        case 0:
            fetchRequest.sortDescriptors = [sortDescriptor]
            if let result = try? dataController.viewContext.fetch(fetchRequest){
                imageInfo = result
                filteredData = imageInfo
                tableView.isHidden = false
            }
            tableView.reloadData()
        case 1:
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
        case 2:
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
        default: break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        switch segue.identifier {
        case toStarterViewController:
            guard let destinvationVC = segue.destination as? BorrowEditorViewController else { return }
            destinvationVC.dataController = self.dataController
        case toEditorViewController:
            guard let destinationVC = segue.destination as? BorrowEditorViewController else { return }
            destinationVC.dataController = self.dataController
        case toCalendarViewController :
            guard let destinationVC = segue.destination as? ImageViewController else { return }
            destinationVC.receivedItem = remindMe
            destinationVC.delegate = self
        default: break
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension BorrowTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: borrowTableViewCell, for: indexPath) as? BorrowTableViewCell
        let memeImages = imageInfo[indexPath.row]
        cell?.returnedIcon.isHidden = true
        cell?.reminderDateIcon.isHidden = true
        let dateToday = Date()
        let date = memeImages.creationDate ?? Date()
        let dateFormatterForCreationDate = DateFormatter()
        dateFormatterForCreationDate.dateFormat = "MMM-dd-yyyy"
        let todaysDate = dateFormatterForCreationDate.string(from: date)
        if #available(iOS 13.0, *) {
            cell?.reminderDate.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        cell?.reminderDate.text = "_"
        if let remdinderDate = memeImages.reminderDate {
            if dateToday > remdinderDate && memeImages.hasBeenReturned != true  {
                cell?.reminderDate.text = "Expired"
                cell?.reminderDate.textColor = .systemPink
            } else if memeImages.hasBeenReturned != true {
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "MMM-dd-yyyy h:mm a"
                let reminderDateToString = dateformatter.string(from: remdinderDate)
                cell?.reminderDate.text = reminderDateToString
                if #available(iOS 13.0, *) {
                    cell?.reminderDateIcon.isHidden = false
                    cell?.returnedIcon.isHidden = true
                    cell?.reminderDateIcon.image = UIImage(systemName: "calendar.circle")
                }
            }
        }
        
        cell?.borrowedDateLabel.text = todaysDate
        cell?.myImageView.contentMode = .scaleAspectFill
        
        if let memeImageData = memeImages.imageData {
            cell?.myImageView.image = UIImage(data: memeImageData)
        }
        
        cell?.accessoryType = .none
        cell?.titleItemLabel.text = memeImages.titleinfo
        cell?.nameOfBorrower.text = memeImages.topInfo
        cell?.statusLabel.text = "Returned?: No"
        if imageInfo[indexPath.row].hasBeenReturned == true && memeImages.animationSeen == false {
            cell?.statusLabel.text = "Returned?: Yes"
            cell?.returnedIcon.isHidden = false
            if #available(iOS 13.0, *) {
                cell?.reminderDateIcon.isHidden = true
                cell?.returnedIcon.image = UIImage(systemName: "checkmark.circle")
                cell?.returnedAnimation()
                for meme in imageInfo {
                    if meme == memeImages {
                        let selectedmeme = meme
                        selectedmeme.animationSeen = true
                        try? self.dataController.viewContext.save()
                        self.dataController.viewContext.refreshAllObjects()
                    }
                }
            }
        } else if imageInfo[indexPath.row].hasBeenReturned == true && memeImages.animationSeen == true {
            cell?.statusLabel.text = "Returned?: Yes"
            cell?.returnedIcon.isHidden = false
            if #available(iOS 13.0, *) {
                cell?.reminderDateIcon.isHidden = true
                cell?.returnedIcon.image = UIImage(systemName: "checkmark.circle")
            }
        }
        return cell ?? UITableViewCell()
        
    }
    
    fileprivate func segmentControler(atSeg: Int, onReturn: Bool) {
        if self.segmentOut.selectedSegmentIndex == 0 {
            tableView.reloadData()
        } else {
            self.segmentOut.selectedSegmentIndex = atSeg
            if self.segmentOut.selectedSegmentIndex == atSeg {
                let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: creationDate, ascending: false)
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
    
    fileprivate func removeCalendarNotification(_ selectedImage: ImageInfo) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.removeScheduleNotification(at: selectedImage.notificationIdentifier ?? "", at: selectedImage)
        selectedImage.reminderDate = nil
        try? self.dataController.viewContext.save()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedImage = self.imageInfo[indexPath.row]
        self.searchBar.resignFirstResponder()
        let alert = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        let markImageAsReturned = selectedImage
        
        if markImageAsReturned.hasBeenReturned == false {
            alert.addAction(UIAlertAction(title: "Mark as returned", style: .default, handler: { _ in
                let markImageAsReturned = selectedImage
                self.removeCalendarNotification(selectedImage)
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
                self.tableView.reloadData()
                self.segmentOut.reloadInputViews()
            }))
            
        }
        
        if selectedImage.hasBeenReturned == false && selectedImage.reminderDate != nil {
            alert.addAction(UIAlertAction(title: "Remove calender reminder", style: .default, handler: { _ in
                self.removeCalendarNotification(selectedImage)
            }))
            
            alert.addAction(UIAlertAction(title: "Change date & time", style: .default, handler: { _ in
                let myphoto = [self.imageInfo[indexPath.row]]
                self.remindMe = myphoto
                self.performSegue(withIdentifier: self.toCalendarViewController, sender: self)
                
            }))
        } else if selectedImage.reminderDate == nil && selectedImage.hasBeenReturned == false {
            alert.addAction(UIAlertAction(title: "Remind me", style: .default, handler: { _ in
                let myphoto = [self.imageInfo[indexPath.row]]
                self.remindMe = myphoto
                self.performSegue(withIdentifier: self.toCalendarViewController, sender: self)
                
            }))
        }
        if imageInfo[indexPath.row].bottomInfo != "" && selectedImage.hasBeenReturned == false {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Send text message", comment: "Default action"), style: .default, handler: { _ in
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
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "PVController") as? PVController else {return}
            if let imageInfo = self.imageInfo[indexPath.row].imageData {
                controller.myImages = UIImage(data: imageInfo)
            }
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
                self.performSegue(withIdentifier: self.toStarterViewController, sender: self)
            }
            self.tableView.reloadData()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteItem = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [weak self] (action, indexPath) in
            guard let self = self else {return}
            self.searchBar.resignFirstResponder()
            let myphoto = self.imageInfo[indexPath.row]
            let selectedImage = self.imageInfo
            for selectedImage in selectedImage  {
                if selectedImage == myphoto {
                    let selectedImage = selectedImage
                    self.dataController.viewContext.delete(selectedImage)
                    try? self.dataController.viewContext.save()
                    self.imageInfo.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .bottom)
                    self.dataController.viewContext.refreshAllObjects()
                    if self.imageInfo.isEmpty == true && self.segmentOut.selectedSegmentIndex == 0 {
                        self.performSegue(withIdentifier: self.toEditorViewController, sender: self)
                    }
                    tableView.reloadData()
                }
            }
            
        })
        deleteItem.backgroundColor = UIColor.systemRed
        let markItemAsReturned = UITableViewRowAction(style: .default, title: "Mark item as returned", handler: { [weak self] (_ , indexPath)  in
            guard let self = self else {return}
            let myphoto = self.imageInfo[indexPath.row]
            let selectImage = self.imageInfo
            for selectedImage in selectImage {
                if selectedImage == myphoto {
                    let markImageAsReturned = selectedImage
                    markImageAsReturned.hasBeenReturned = true
                    try? self.dataController.viewContext.save()
                    tableView.cellForRow(at: indexPath)
                    self.dataController.viewContext.refreshAllObjects()
                    self.segmentControler(atSeg: 2, onReturn: false)
                    self.segmentOut.reloadInputViews()
                }
            }
            
        })
        let markItemAsNotReturned = UITableViewRowAction(style: .default, title: "Mark item as not returned", handler: { [weak self] (_ , indexPath)  in
            guard let self = self else {return}
            let myphoto = self.imageInfo[indexPath.row]
            let selectImage = self.imageInfo
            for selectedImage in selectImage {
                if selectedImage == myphoto {
                    let markImageAsReturned = selectedImage
                    markImageAsReturned.hasBeenReturned = false
                    try? self.dataController.viewContext.save()
                    tableView.cellForRow(at: indexPath)
                    self.dataController.viewContext.refreshAllObjects()
                    self.segmentControler(atSeg: 1, onReturn: true)
                    self.segmentOut.reloadInputViews()
                }
            }
            
        })
        if imageInfo[indexPath.row].hasBeenReturned == true {
            markItemAsNotReturned.backgroundColor = .systemTeal
            return [deleteItem, markItemAsNotReturned]
        }
        markItemAsReturned.backgroundColor = UIColor.systemGreen
        self.searchBar.resignFirstResponder()
        return [deleteItem, markItemAsReturned]
    }
}

//extension BorrowTableViewController: GADBannerViewDelegate {
//    private func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        print("Recieved ad")
//    }
//    
//    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        print(error)
//    }
//}
