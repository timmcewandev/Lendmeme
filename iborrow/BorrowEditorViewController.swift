
//  MemeEditorViewController
//
//  Created by sudo on 12/6/17.
//  Copyright © 2017 sudo. All rights reserved.
//

import UIKit
import Foundation

class BorrowEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  var borrow: [BorrowInfo]!
    var dataController: DataController! = nil
  // MARK: Outlets
  
  @IBOutlet var toolbar: UIToolbar!
  @IBOutlet var shareOUT: UIBarButtonItem!
  @IBOutlet var bottomTextOUT: UITextField!
  @IBOutlet var topTextOUT: UITextField!
  @IBOutlet var imageView: UIImageView!
  
  let borrowTextAttributes: [String : Any] = [
    NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
    NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
    NSAttributedStringKey.strokeWidth.rawValue : -4.0,
    NSAttributedStringKey.backgroundColor.rawValue: UIColor.clear
  ]
  // MARK: Override
  override func viewDidLoad() {
    super.viewDidLoad()
    configureShareOut(isEnabled: false)
    prepareTextField(textField: topTextOUT)
    prepareTextField(textField: bottomTextOUT)
    self.tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeToKeyboardNotifications()
    self.toolbar.isHidden = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
    configureShareOut(isEnabled: false)
  }
  
  
  // MARK: Action
  @IBAction func pickedPhoto(_ sender: Any) {
    pick(sourceType: .photoLibrary)
  }
  
  @IBAction func addCamera(_ sender: Any) {
    camera()
  }
  
  @IBAction func cancelBTN(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    
  }
  
  @IBAction func share(sender: AnyObject) {
    let memedImage = generateMemedImage()
    let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
    controller.completionWithItemsHandler = {
      (_,success,_,_) in
      if success{
        self.save()
      } else {
        self.configureShareOut(isEnabled: false)
      }
    }
    self.present(controller, animated: true, completion: nil)
  }
  
  // MARK: Functions
  func pick(sourceType: UIImagePickerControllerSourceType){
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    configureShareOut(isEnabled: true)
    present(imagePicker, animated: true, completion: nil)
  }
  
  func camera()
  {
    if UIImagePickerController.isSourceTypeAvailable(.camera){
      let myPickerController = UIImagePickerController()
      myPickerController.delegate = self
      myPickerController.sourceType = .camera
      present(myPickerController, animated: true, completion: nil)
    }
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      imageView.contentMode = .scaleAspectFit
      imageView.image = pickedImage
      self.configureShareOut(isEnabled: true)
    }
    dismiss(animated: true, completion: nil)
  }
  func resetFrame() {
    self.view.frame.origin.y = 0
  }
  
  func keyboardHeight(notification: NSNotification) -> CGFloat {
    if let rect = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue {
      return rect.cgRectValue.height
    } else {
      return CGFloat(0)
    }
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    resetFrame()
    return false
  }
  
  func generateMemedImage() -> UIImage {
    UIGraphicsBeginImageContext(view.frame.size)
    view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
    let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return memedImage
  }
  
  func save() {
    toolbar.isHidden = true
    let memedImage = generateMemedImage()
    let borrowInfo = BorrowInfo(topString: topTextOUT.text!, bottomString: bottomTextOUT.text!, originalImage: imageView.image!, borrowImage: memedImage)
    let helloWorld = ImageInfo(context: dataController.viewContext)
    helloWorld.imageData = UIImagePNGRepresentation(borrowInfo.borrowImage)
    helloWorld.topInfo = borrowInfo.topString
    helloWorld.bottomInfo = borrowInfo.bottomString
    helloWorld.creationDate = Date()
    try? dataController.viewContext.save()
     self.toolbar.isHidden = true
    navigationController?.popViewController(animated: true)//    let object = UIApplication.shared.delegate
//    let appDelegate = object as! AppDelegate
//    let data = Data()
//
//    data.topText = borrowInfo.topString
//    data.bottomText = borrowInfo.bottomString
//    data.image = UIImagePNGRepresentation(borrowInfo.borrowImage)! as NSData?
//
//    appDelegate.borrowInfo.append(borrowInfo)
   
  }
  
  func configureShareOut(isEnabled: Bool){
    shareOUT.isEnabled = isEnabled
  }
  
  func prepareTextField(textField: UITextField) {
    textField.defaultTextAttributes = borrowTextAttributes
    textField.delegate = self
  }
  
  
  func subscribeToKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
  }
  
  func unsubscribeFromKeyboardNotifications() {
    
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)    }
  // MARK: Objects
  @objc func keyboardWillShow(notification: NSNotification) {
    if bottomTextOUT.isFirstResponder {
      view.frame.origin.y = -keyboardHeight(notification: notification)
    }
  }
  
  @objc func keyboardWillHide(notification: NSNotification) {
    resetFrame()
  }
  
}





