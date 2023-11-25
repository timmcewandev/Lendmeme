//
//  Created by sudo on 1/9/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

final class BorrowTableViewController: UIViewController, MFMessageComposeViewControllerDelegate, UNUserNotificationCenterDelegate {
    
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
    let headerTitles = ["Not Returned", "Returned", "Expired"]
    let refreshControl = UIRefreshControl()
    
    
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
        super.viewWillAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
        addInRefreshPullDownControl()
        fetchAllMemedInfo()
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
        if self.imageInfo[1].isEmpty { return }
        let alert = UIAlertController(title: "⚠️ Warning ⚠️", message: "This will delete all items in returned section", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Nervermind", style: .default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "Delete all", style: .destructive, handler: { _ in
            self.deleteAllMemes()
        }))
        
        present(alert, animated: true)
    }
    
    func removeCalendarNotification(_ selectedImage: ImageInfo) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.removeScheduleNotification(at: selectedImage.notificationIdentifier ?? "", at: selectedImage)
        selectedImage.reminderDate = nil
        try? self.dataController.viewContext.save()
        self.dataController.viewContext.refreshAllObjects()
        self.tableView.reloadData()
    }
    
    func addInRefreshPullDownControl() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.backgroundColor = .systemBlue
        refreshControl.tintColor = .white
        tableView.addSubview(refreshControl)
    }
    
    func fetchAllMemedInfo() {
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        fetchRequest.shouldRefreshRefetchedObjects = true
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            let hasBeenReturned = result.filter ({ return $0.hasBeenReturned })
            let hasNotBeenReturned = result.filter ({ return !$0.hasBeenReturned })
            let expired = result.filter ({ return $0.reminderDate ?? Date() <= Date() })

            imageInfo = [hasNotBeenReturned, hasBeenReturned, expired]
        }
    }
    
    // Mark: All fetch and delete memes
    func deleteAllMemes() {
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
            
        fetchRequest.shouldRefreshRefetchedObjects = true
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? self.dataController.viewContext.fetch(fetchRequest){
            let hasBeenReturned = result.filter ({ return $0.hasBeenReturned })
            _ = result.filter ({ return !$0.hasBeenReturned })
            for i in hasBeenReturned {
                self.dataController.viewContext.delete(i)
            }
            try? self.dataController.viewContext.save()
            self.dataController.viewContext.refreshAllObjects()
            self.fetchAllMemedInfo()
            self.tableView.reloadData()
        }
        
    }
    func deleteSelectedMeme(selectedMeme: ImageInfo, indexPath: IndexPath) {
        
        self.dataController.viewContext.delete(selectedMeme)
        try? self.dataController.viewContext.save()
        self.dataController.viewContext.refreshAllObjects()
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
            
        fetchRequest.shouldRefreshRefetchedObjects = true
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? self.dataController.viewContext.fetch(fetchRequest){
            var hasBeenReturned = result.filter ({ return $0.hasBeenReturned })
            let hasNotBeenReturned = result.filter ({ return !$0.hasBeenReturned })
            hasBeenReturned = []
            self.imageInfo = [hasNotBeenReturned, hasBeenReturned]

        if self.imageInfo.isEmpty {
            self.performSegue(withIdentifier: Constants.Segue.toStarterViewController, sender: self)
        }
        self.fetchAllMemedInfo()
        self.tableView.reloadData()
    }
    }
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
        } else if section == 2 {
            return self.imageInfo[2].count
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
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
        trashHideButton.contentMode = .scaleAspectFit
        let headerLabel = UILabel(frame: CGRect(x: 12, y: 0, width:
                                                    tableView.bounds.size.width, height: 50))
        headerLabel.textColor = .label
        headerView.backgroundColor = .systemBackground
        headerLabel.text = "\(headerTitles[section])"
        headerLabel.textAlignment = .left
        headerView.addSubview(headerLabel)
        let config = UIImage.SymbolConfiguration(
            pointSize: 25, weight: .thin, scale: .medium)
        // code for adding button to right corner of section header
        
        switch headerTitles[section] {
        case "Not Returned":
            let image = UIImage(systemName: "plus", withConfiguration: config)
            showHideButton.setImage(image, for: .normal)
            showHideButton.addTarget(self, action: #selector(btnShowHideTapped), for: .touchUpInside)
            headerView.addSubview(showHideButton)
        case "Returned":
            if self.imageInfo[1].isEmpty { return headerView }
            let image = UIImage(systemName: "trash", withConfiguration: config)
            trashHideButton.setImage(image, for: .normal)
            trashHideButton.addTarget(self, action: #selector(trashAll), for: .touchUpInside)
            headerView.addSubview(trashHideButton)
        case "Expired": break
        default: break
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return BorrowTableUtilities.getCellForRowIndex(tableView, cellForRowAt: indexPath, self.imageInfo)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        return 
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
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
                self.dataController.viewContext.refreshAllObjects()
                self.fetchAllMemedInfo()
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
                self.fetchAllMemedInfo()
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
            self.deleteSelectedMeme(selectedMeme: selectedImage, indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteItem = UITableViewRowAction(style: .destructive, title: Constants.CommandListText.delete, handler: { [weak self] (action, indexPath) in
//            guard let self = self else {return}
//            self.searchBar.resignFirstResponder()
//            let selectedMeme = self.imageInfo[indexPath.section][indexPath.row]
//            self.deleteSelectedMeme(selectedMeme: selectedMeme, indexPath: indexPath)
//            
//        })
//        if #available(iOS 13.0, *) {
//            deleteItem.backgroundColor = UIColor.systemPink
//        } else {
//            // Fallback on earlier versions
//        }
//
//        self.searchBar.resignFirstResponder()
//        return [deleteItem]
//    }
}
