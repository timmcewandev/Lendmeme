//
//  OptionTableViewController.swift
//  iborrow
//
//  Created by sudo on 3/1/19.
//  Copyright © 2019 sudo. All rights reserved.
//

import UIKit
import MessageUI
import FittedSheets

class OptionTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    controller.dismiss(animated: true, completion: nil)
  }
  var memberImage: UIImage?
  var memberNumber: String?
  let options = ["View Image", "Send a text"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    tableView.tableHeaderView?.backgroundColor = UIColor.white
    return "What would you like to do?"
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toSecond" {
      let vc = segue.destination as! ImageViewController
      vc.myImages = memberImage
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return 2
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let enumValue = options[indexPath.row]
    cell.textLabel?.text = enumValue
    return cell
  }
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let indexPath = tableView.indexPathForSelectedRow
    let currentCell = tableView.cellForRow(at: indexPath!)
    
    switch currentCell?.textLabel?.text {
    case "Send a text":
      let composeVC = MFMessageComposeViewController()
      composeVC.messageComposeDelegate = self
      guard let number = memberNumber else { return }
      composeVC.recipients = ["\(number)"]
      composeVC.body = "Hello, I was wondering if you are done with my item? Is there a time you could return it?"
      if MFMessageComposeViewController.canSendText() {
        self.present(composeVC, animated: true, completion: nil)
      } else {
        print("Can't send messages.")
      }
    case "View Image":
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
      controller.myImages = memberImage
      let sheet = SheetViewController(controller: controller, sizes: [.fullScreen])
      sheet.adjustForBottomSafeArea = true
      
      self.present(sheet, animated: false, completion: nil)
      performSegue(withIdentifier: "toSecond", sender: self)
    default:
      print("Crap this failed")
    }
  }
}
