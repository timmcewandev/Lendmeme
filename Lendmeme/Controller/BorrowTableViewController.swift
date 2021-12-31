//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit

import CoreData
import MessageUI

class BorrowTableViewController: UIViewController, passBackRowAndDateable, MFMessageComposeViewControllerDelegate, UNUserNotificationCenterDelegate {
    func getRowAndDate(date: Date, row: Int, section: Int) {
        for (index, imageInfo) in imageInfo.enumerated() {
            if imageInfo == self.imageInfo[row] {
                imageInfo[row].reminderDate = date
                imageInfo[row].timeHasExpired = false
                if imageInfo[row].reminderDate != nil {
                    self.moreThanOne += 1
                }
                try? self.dataController.viewContext.save()
                self.dataController.viewContext.refreshAllObjects()
                let delegate = UIApplication.shared.delegate as? AppDelegate
                delegate?.scheduleNotification(at: date, name: imageInfo[row].titleinfo ?? "", memedImage: imageInfo[row])
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.moreThanOne == 1 {
//                self.refreshAll()
            }
        }
        
    }
    let headerTitles = ["Not Returned", "Returned"]
    let refreshControl = UIRefreshControl()
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dropdown: UITextField!
    @IBOutlet weak var categoriesButton: UITextField!

    
    // MARK: - Properties
    let button = UIButton()
    let secondDatePicker = UIDatePicker()
    var dataController:DataController!
    var imageInfo: [[ImageInfo]] = [[]]
    var expired: [ImageInfo] = []
    var filteredData: [[ImageInfo]] = [[]]
    var reminderDate: Date?
    var categoryList: [String] = []
    var isRunningLoop: Bool = false
    var moreThanOne = 0
    var selectedBorrowedInfo: ImageInfo?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        searchBar.delegate = self
        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        let nib = UINib(nibName: Constants.Cell.borrowTableViewCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.Cell.borrowTableViewCell)
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        fetchRequest.shouldRefreshRefetchedObjects = true
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            let hasBeenReturned = result.filter ({ return $0.hasBeenReturned })
            let hasNotBeenReturned = result.filter ({ return !$0.hasBeenReturned })
            imageInfo = [hasNotBeenReturned, hasBeenReturned]
            filteredData = imageInfo
        }
        navigationItem.hidesSearchBarWhenScrolling = false
//        self.refreshAll()
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
           refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.backgroundColor = .systemBlue
        refreshControl.tintColor = .white
           tableView.addSubview(refreshControl)
        tableView.reloadData()
    }
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    @objc func btnShowHideTapped(_ sender: AnyObject) {
       // Code to refresh table view
        self.performSegue(withIdentifier: Constants.Segue.toStarterViewController, sender: self)
    }
    @objc func trashAll(_ sender: AnyObject) {
        for (indexer, element) in imageInfo.enumerated() {
            if indexer == 2 {
//                let me = imageInfo[indexer][element];)
            }
        }
        try? dataController.viewContext.save()
        self.dataController.viewContext.refreshAllObjects()
        self.tableView.reloadData()
    }
//    func refreshAll(interval:TimeInterval = 30) {
//        guard interval > 0 else { return }
//        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
//            let totalReminderDates = self.imageInfo.contains(where: { image in
//                if image.reminderDate != nil {
//                    return true
//                }else {
//                    return false
//                }
//            })
//            if totalReminderDates == true {
//                self.moreThanOne = 1
//                self.refreshAll(interval: interval)
//                self.tableView.reloadData()
//            } else {
//                self.moreThanOne = 0
//                self.tableView.reloadData()
//                return
//            }
//        }
//    }
    // MARK: - Actions
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        switch segue.identifier {
        case Constants.Segue.toStarterViewController:
            guard let destinvationVC = segue.destination as? BorrowEditorViewController else { return }
            destinvationVC.dataController = self.dataController
            if selectedBorrowedInfo != nil {
                destinvationVC.selectedBorrowedInfo = selectedBorrowedInfo
                destinvationVC.onEdit = true
            }
        case Constants.Segue.toEditorViewController:
            guard let destinationVC = segue.destination as? BorrowEditorViewController else { return }
            destinationVC.dataController = self.dataController
        default: break
        }
        selectedBorrowedInfo = nil
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension BorrowTableViewController: UITableViewDelegate, UITableViewDataSource {
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if section == 0 {
            return self.imageInfo[0].count
         } else if section == 1 {
             return self.imageInfo[1].count
         } else {
             return 0
         }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
         return headerTitles.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let verticalPadding: CGFloat = 2

        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }


    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        // code for adding centered title
        let showHideButton: UIButton = UIButton(frame: CGRect(x:headerView.frame.size.width - 100, y:12, width:100, height:25))
        let trashHideButton: UIButton = UIButton(frame: CGRect(x:headerView.frame.size.width - 100, y:12, width:100, height:25))
           let headerLabel = UILabel(frame: CGRect(x: 12, y: 0, width:
               tableView.bounds.size.width, height: 50))
        headerLabel.textColor = .label
        headerView.backgroundColor = .systemBackground
        headerLabel.text = "\(headerTitles[section]): \(self.imageInfo[section].count)"
        headerLabel.textAlignment = .left
           headerView.addSubview(headerLabel)
        let config = UIImage.SymbolConfiguration(
            pointSize: 25, weight: .thin, scale: .medium)
           // code for adding button to right corner of section header
        if headerTitles[section] != "Returned" {
            let image = UIImage(systemName: "plus", withConfiguration: config)
            showHideButton.setImage(image, for: .normal)
            showHideButton.addTarget(self, action: #selector(btnShowHideTapped), for: .touchUpInside)
            headerView.addSubview(showHideButton)
        }else {
            let image = UIImage(systemName: "trash", withConfiguration: config)
            trashHideButton.setImage(image, for: .normal)
            trashHideButton.addTarget(self, action: #selector(trashAll), for: .touchUpInside)
            headerView.addSubview(trashHideButton)
        }
           
        
           return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.borrowTableViewCell, for: indexPath) as? BorrowTableViewCell
        let memeImages = self.imageInfo[indexPath.section][indexPath.row]
        cell?.imageCell = memeImages
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedImage = self.imageInfo[indexPath.section][indexPath.row]
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
                let imageInfoSorted = Array(self.imageInfo.joined())
                let hasBeenReturned = imageInfoSorted.filter ({ return $0.hasBeenReturned })
                let hasNotBeenReturned = imageInfoSorted.filter ({ return !$0.hasBeenReturned })
                self.imageInfo = [hasNotBeenReturned, hasBeenReturned]
                self.filteredData = [hasNotBeenReturned, hasBeenReturned]
                self.dataController.viewContext.refreshAllObjects()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
                let selectedImage = self.imageInfo[indexPath.section][indexPath.row]
                self.selectedBorrowedInfo = selectedImage
                self.performSegue(withIdentifier: Constants.Segue.toStarterViewController, sender: self)
            }))
            guard let name = selectedImage.nameOfPersonBorrowing else { return }
            alert.addAction(UIAlertAction(title: "Call: \(name)", style: .default, handler: { _ in
                guard let userPhone = selectedImage.bottomInfo else { return }
                guard let number = URL(string: "tel://" + userPhone) else { return }
                UIApplication.shared.open(number)
            }))
        } else {
            alert.addAction(UIAlertAction(title: Constants.CommandListText.markAsNotReturned, style: .default, handler: { _ in
                let selectedImage = self.imageInfo[indexPath.section][indexPath.row]
                let markImageAsReturned = selectedImage
                markImageAsReturned.hasBeenReturned = false
                try? self.dataController.viewContext.save()
                tableView.cellForRow(at: indexPath)
                self.dataController.viewContext.refreshAllObjects()
                let cool = Array(self.imageInfo.joined())
                let hasBeenReturned = cool.filter ({ return $0.hasBeenReturned })
                let hasNotBeenReturned = cool.filter ({ return !$0.hasBeenReturned })
                self.imageInfo = [hasNotBeenReturned, hasBeenReturned]
                self.filteredData = [hasNotBeenReturned, hasBeenReturned]
                self.dataController.viewContext.refreshAllObjects()
                self.tableView.reloadData()
            }))
        }
        if self.imageInfo[indexPath.section][indexPath.row].bottomInfo != "" && selectedImage.hasBeenReturned == false {
            alert.addAction(UIAlertAction(title: NSLocalizedString(Constants.MesageText.sendMessage, comment: "Default action"), style: .default, handler: { _ in
                let composeVC = MFMessageComposeViewController()
                composeVC.messageComposeDelegate = self
                guard let number = self.imageInfo[indexPath.section][indexPath.row].bottomInfo else {return}
                guard let image = self.imageInfo[indexPath.section][indexPath.row].imageData else {return}
                if let name = self.imageInfo[indexPath.section][indexPath.row].nameOfPersonBorrowing, let itemBorrowed = self.imageInfo[indexPath.section][indexPath.row].titleinfo?.lowercased() {
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
            if let imageInfo = self.imageInfo[indexPath.section][indexPath.row].imageData {
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
            let selectedImage = self.imageInfo[indexPath.section][indexPath.row]

            self.dataController.viewContext.delete(selectedImage)
            try? self.dataController.viewContext.save()
            self.imageInfo.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            self.filteredData.remove(at: indexPath.row)
            self.dataController.viewContext.refreshAllObjects()
            if self.imageInfo.count == 0 {
                self.performSegue(withIdentifier: Constants.Segue.toStarterViewController, sender: self)
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteItem = UITableViewRowAction(style: .destructive, title: Constants.CommandListText.delete, handler: { [weak self] (action, indexPath) in
            guard let self = self else {return}
            self.searchBar.resignFirstResponder()
            let myphoto = self.imageInfo[indexPath.section][indexPath.row]
            let selectedImage = self.imageInfo
//            for selectedImage in selectedImage  {
//                if selectedImage == myphoto {
//                    let selectedImage = selectedImage
//                    self.dataController.viewContext.delete(selectedImage)
//                    try? self.dataController.viewContext.save()
//                    self.imageInfo.remove(at: indexPath.row)
//                    self.filteredData.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .bottom)
//                    self.dataController.viewContext.refreshAllObjects()
//                    id
//                    tableView.reloadData()
//                }
//            }
            
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
        self.dataController.viewContext.refreshAllObjects()
        self.tableView.reloadData()
    }

}
