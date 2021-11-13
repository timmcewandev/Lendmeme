//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//
import UIKit

import CoreData
import MessageUI
import GoogleMobileAds

class BorrowTableViewController: UIViewController, passBackRowAndDateable, MFMessageComposeViewControllerDelegate, UNUserNotificationCenterDelegate {
    func getRowAndDate(date: Date, row: Int) {
        
        for imageInfo in self.imageInfo {
            if imageInfo == self.imageInfo[row] {
                imageInfo.reminderDate = date
                imageInfo.timeHasExpired = false
                if imageInfo.reminderDate != nil {
                    self.moreThanOne += 1
                }
                try? self.dataController.viewContext.save()
                self.dataController.viewContext.refreshAllObjects()
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.scheduleNotification(at: date, name: imageInfo.titleinfo ?? "", memedImage: imageInfo)
            }
        }
        print("aaaa \(self.moreThanOne)")
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.moreThanOne == 1 {
                self.refreshAll()
            }
        }
        
    }
    
    // MARK: - Outlets
    @IBOutlet weak var segmentOut: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdown: UITextField!
    @IBOutlet weak var categoriesButton: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    // MARK: - Properties
    let button = UIButton()
    let secondDatePicker = UIDatePicker()
    var hasBeenSeen = false
    var dataController:DataController!
    var imageInfo: [ImageInfo] = []
    var filteredData: [ImageInfo] = []
    var reminderDate: Date?
    var categoryList: [String] = []
    var isRunningLoop: Bool = false
    var moreThanOne = 0
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        searchBar.delegate = self
        let nib = UINib(nibName: Constants.Cell.borrowTableViewCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.Cell.borrowTableViewCell)
                
//                bannerView.adUnitID = "ca-app-pub-4726435113512089/9616934090" //Real
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //fake
//                bannerView.rootViewController = self
//        bannerView.delegate = self
//                bannerView.load(GADRequest())
                
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            imageInfo = result
            filteredData = imageInfo
            tableView.isHidden = false
        }
        self.segmentOut.selectedSegmentIndex = 0
        self.segmentOut.reloadInputViews()
        if imageInfo.count == 0 && self.segmentOut.selectedSegmentIndex == 0   {
            performSegue(withIdentifier: Constants.Segue.toStarterViewController, sender: self)
        }
        self.navigationController?.isNavigationBarHidden = false
        segmentControler(atSeg: 0, onReturn: true)
        categoryList = Constants.Categories.gatherCategories()
        self.refreshAll()
    }

    
    func refreshAll(interval:TimeInterval = 30) {
        guard interval > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            let cool = self.imageInfo.contains(where: { image in
                if image.reminderDate != nil {
                    return true
                }else {
                    return false
                }
            })
            if cool == true {
                self.moreThanOne = 1
                self.refreshAll(interval: interval)
                self.tableView.reloadData()
                print("refresh DATA")
            } else {
                self.tableView.reloadData()
                print("Terminate LOOP")
                self.moreThanOne = 0
                return
            }
        }
    }
    // MARK: - Actions
    @IBAction func segmentControl(_ sender: Any) {
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: false)
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
    
    @IBAction func categoriesButtonTapped(_ sender: Any) {
        searchBar.isHidden = true
        dropdown.isHidden = false
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        switch segue.identifier {
        case Constants.Segue.toStarterViewController:
            guard let destinvationVC = segue.destination as? BorrowEditorViewController else { return }
            destinvationVC.dataController = self.dataController
        case Constants.Segue.toEditorViewController:
            guard let destinationVC = segue.destination as? BorrowEditorViewController else { return }
            destinationVC.dataController = self.dataController
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.borrowTableViewCell, for: indexPath) as? BorrowTableViewCell
        
        let memeImages = self.imageInfo[indexPath.row]
        cell?.returnedIcon.isHidden = true
//        cell?.reminderDateIcon.isHidden = true
        let dateToday = Date()
        let date = memeImages.creationDate ?? Date()
        let dateFormatterForCreationDate = DateFormatter()
        dateFormatterForCreationDate.dateFormat = Constants.DateText.dateOnly
        let todaysDate = dateFormatterForCreationDate.string(from: date)
        cell?.borrowedDateLabel.text = "Date Borrowed: \(todaysDate)"
        cell?.scheduleBTN.backgroundColor = .systemBlue
        
        if let remdinderDate = memeImages.reminderDate {
            if dateToday > remdinderDate && memeImages.hasBeenReturned != true {
                cell?.scheduleBTN.setTitle("Re-schedule reminder" , for: .highlighted)
                cell?.scheduleBTN.backgroundColor = .systemPink
                
            }
        } else {
            cell?.scheduleBTN.setTitle("Set Reminder Date 📅", for: .normal)
        }
        cell?.delegate = self
        cell?.myImageView.contentMode = .scaleAspectFill
        
        if let memeImageData = memeImages.imageData {
            cell?.myImageView.image = UIImage(data: memeImageData)
        }
        
        cell?.accessoryType = .none
        if let top = memeImages.titleinfo {
            cell?.titleItemLabel.text = top
        }
        cell?.nameOfBorrower.text = memeImages.topInfo
        cell?.statusLabel.textColor = .systemGroupedBackground
        
        if imageInfo[indexPath.row].hasBeenReturned == true && memeImages.animationSeen == false {

            cell?.statusLabel.textColor = .systemGroupedBackground
            removeCalendarNotification(memeImages)
            cell?.returnedIcon.isHidden = false
            
//                cell?.reminderDateIcon.isHidden = true
            cell?.returnedIcon.image = UIImage(systemName: Constants.SymbolsImage.checkMarkCircleFilled)
            for meme in imageInfo {
                if meme == memeImages {
                    let selectedmeme = meme
                    selectedmeme.animationSeen = true
                    try? self.dataController.viewContext.save()
                    self.dataController.viewContext.refreshAllObjects()
                    }
            }
        } else if imageInfo[indexPath.row].hasBeenReturned == true && memeImages.animationSeen == true {
            cell?.statusLabel.textColor = .systemBlue
            cell?.returnedIcon.isHidden = false
            cell?.returnedIcon.tintColor = .systemGreen
//            cell?.calendarTextField.isHidden = true
            cell?.returnedIcon.image = UIImage(systemName: Constants.SymbolsImage.checkMarkCircleFilled)
            cell?.scheduleBTN.isHidden = true
        } else {
           
            cell?.statusLabel.textColor = .label
            cell?.statusLabel.adjustsFontSizeToFitWidth = true
            cell?.scheduleBTN.isHidden = false
        }
        if memeImages.reminderDate != nil {
            let myDate = Date()
            if memeImages.reminderDate! >= myDate {
                if let date = memeImages.reminderDate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = Constants.DateText.dateAndTime
                    cell?.statusLabel.text = "Schedule is set for 👇\nReturn Date: \(dateFormatter.string(from: date))"
                    cell?.scheduleBTN.setTitle("Re-schedule reminder", for: .normal)
                    cell?.scheduleBTN.backgroundColor = .systemIndigo
                }
                
            } else {
                cell?.scheduleBTN.setTitle("Re-schedule reminder", for: .normal)
                cell?.statusLabel.text = "Schedule Expired 🙈"
                memeImages.timeHasExpired = true
                memeImages.reminderDate = nil
                try? self.dataController.viewContext.save()
                dataController.viewContext.refreshAllObjects()
            }
            
        }else {
//            let cool = memeImages.hasBeenReturned == true ? "\(Constants.NameConstants.statusReturned) 👏" : "* Click on \"Set reminder Date\" to set a return date 👉"
//            cell?.statusLabel.text = cool
        }

        cell?.statusLabel.adjustsFontSizeToFitWidth = true
        return cell ?? UITableViewCell()
    }
    
    fileprivate func segmentControler(atSeg: Int, onReturn: Bool) {
        if self.segmentOut.selectedSegmentIndex == 0 {
            tableView.reloadData()
        } else {
            self.segmentOut.selectedSegmentIndex = atSeg
            if self.segmentOut.selectedSegmentIndex == atSeg {
                let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: false)
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
        let selectedImage = self.imageInfo[indexPath.row]
        self.searchBar.resignFirstResponder()

        let alert = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        let markImageAsReturned = selectedImage

        if markImageAsReturned.hasBeenReturned == false {
            alert.addAction(UIAlertAction(title: Constants.CommandListText.markAsReturned, style: .default, handler: { _ in
                let markImageAsReturned = selectedImage
                self.removeCalendarNotification(selectedImage)
                markImageAsReturned.hasBeenReturned = true
                markImageAsReturned.reminderDate = nil
                try? self.dataController.viewContext.save()
                tableView.cellForRow(at: indexPath)
                self.dataController.viewContext.refreshAllObjects()
                self.segmentControler(atSeg: 2, onReturn: false)

                self.segmentOut.reloadInputViews()
            }))
            alert.addAction(UIAlertAction(title: "Call: \(selectedImage.titleinfo!)", style: .default, handler: { _ in
                guard let userPhone = selectedImage.bottomInfo else { return }
                guard let number = URL(string: "tel://" + userPhone) else { return }
                UIApplication.shared.open(number)
            }))
        } else {
            alert.addAction(UIAlertAction(title: Constants.CommandListText.markAsNotReturned, style: .default, handler: { _ in
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

        if imageInfo[indexPath.row].bottomInfo != "" && selectedImage.hasBeenReturned == false {
            alert.addAction(UIAlertAction(title: NSLocalizedString(Constants.MesageText.sendMessage, comment: "Default action"), style: .default, handler: { _ in
                let composeVC = MFMessageComposeViewController()
                composeVC.messageComposeDelegate = self
                guard let number = self.imageInfo[indexPath.row].bottomInfo else {return}
                guard let image = self.imageInfo[indexPath.row].imageData else {return}
                if let name = self.imageInfo[indexPath.row].topInfo, let itemBorrowed = self.imageInfo[indexPath.row].titleinfo?.lowercased() {
                    composeVC.body = Constants.MesageText.getNameAndItemBorrowed(name: name, item: itemBorrowed)
                    composeVC.addAttachmentData(image, typeIdentifier: "public.data", filename: "\(itemBorrowed).png")
                } else {
                    composeVC.body = Constants.MesageText.noNameOrItem
                    composeVC.addAttachmentData(image, typeIdentifier: "public.data", filename: "lendmeme.png")
                }
                composeVC.recipients = ["\(number)"]

                if MFMessageComposeViewController.canSendText() {
                    self.present(composeVC, animated: true, completion: nil)
                }
            }))

        }
        alert.addAction(UIAlertAction(title: Constants.CommandListText.viewImage, style: .default, handler: { _ in
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: Constants.Segue.pvController) as? PVController else { return }
            if let imageInfo = self.imageInfo[indexPath.row].imageData {
                controller.myImages = UIImage(data: imageInfo)
            }
            if let sheet = controller.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                    sheet.largestUndimmedDetentIdentifier = .large
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                }
            self.present(controller, animated: true, completion: nil)

        }))

        alert.addAction(UIAlertAction(title: Constants.CommandListText.delete, style: .destructive, handler: { _ in
            let selectedImage = self.imageInfo[indexPath.row]

            self.dataController.viewContext.delete(selectedImage)
            try? self.dataController.viewContext.save()
            self.imageInfo.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            self.dataController.viewContext.refreshAllObjects()
            if self.imageInfo.count == 0 {
                self.performSegue(withIdentifier: Constants.Segue.toStarterViewController, sender: self)
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))

//        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
//            NSLog("The \"OK\" alert occured.")
//        }))
////            addActionSheetForiPad(actionSheet: alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteItem = UITableViewRowAction(style: .destructive, title: Constants.CommandListText.delete, handler: { [weak self] (action, indexPath) in
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
                        self.performSegue(withIdentifier: Constants.Segue.toEditorViewController, sender: self)
                    }
                    tableView.reloadData()
                }
            }
            
        })
        if #available(iOS 13.0, *) {
            deleteItem.backgroundColor = UIColor.systemPink
        } else {
            // Fallback on earlier versions
        }


        self.searchBar.resignFirstResponder()
        return [deleteItem]
    }
    
    fileprivate func removeCalendarNotification(_ selectedImage: ImageInfo) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.removeScheduleNotification(at: selectedImage.notificationIdentifier ?? "", at: selectedImage)
        selectedImage.reminderDate = nil
        try? self.dataController.viewContext.save()
        self.tableView.reloadData()
    }

}

extension BorrowTableViewController {
//  public func addActionSheetForiPad(actionSheet: UIAlertController) {
//    if let popoverPresentationController = actionSheet.popoverPresentationController {
//      popoverPresentationController.sourceView = self.view
//      popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//      popoverPresentationController.permittedArrowDirections = []
//    }
//  }
}
extension BorrowTableViewController: GADBannerViewDelegate {
    private func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Recieved ad")
    }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
