
//  Copyright © 2017 McEwanTech. All rights reserved.
//

import UIKit
import Foundation

class BorrowEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    let borrow: [BorrowInfo]! = nil
    var dataController: DataController! = nil

    let borrowTextAttributes: [String : Any] = [
        NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
        NSAttributedStringKey.strokeWidth.rawValue : -3.0,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
    ]
    
    // MARK: Outlets
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareOUT: UIBarButtonItem!
    @IBOutlet weak var bottomTextOUT: UITextField!
    @IBOutlet weak var topTextOUT: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureShareOut(isEnabled: false)
        prepareTextField(textField: topTextOUT, name: "Enter name")
        prepareTextField(textField: bottomTextOUT, name: "Enter Phone#")
        self.tabBarController?.tabBar.isHidden = true
        bottomTextOUT.inputAccessoryView = accessoryView()
        bottomTextOUT.inputAccessoryView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        view.addSubview(bottomTextOUT)
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
    
    
    // MARK: Interactions
    @IBAction func pickedPhoto(_ sender: Any) {
        pick(sourceType: .photoLibrary)
    }
    
    @IBAction func addCamera(_ sender: Any) {
        camera()
    }
    
    @IBAction func cancelBTN(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func share(sender: AnyObject) {
        self.save()
    }
    
    // MARK: Functions
    func pick(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        configureShareOut(isEnabled: true)
        present(imagePicker, animated: true, completion: nil)
    }
    func camera() {
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
        if topTextOUT.text == "" {
            topTextOUT.placeholder = ""
        }
        if bottomTextOUT.text == "" {
            bottomTextOUT.placeholder = ""
        }
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    func save() {
        toolbar.isHidden = true
        let memedImage = generateMemedImage()
        let borrowInfo = BorrowInfo(topString: topTextOUT.text!, bottomString: bottomTextOUT.text!, originalImage: imageView.image!, borrowImage: memedImage, hasBeenReturned: false)
        let getImageInfo = ImageInfo(context: dataController.viewContext)
        getImageInfo.imageData = UIImagePNGRepresentation(borrowInfo.borrowImage)
        getImageInfo.topInfo = borrowInfo.topString
        getImageInfo.bottomInfo = borrowInfo.bottomString
        getImageInfo.creationDate = Date()
        getImageInfo.hasBeenReturned = false
        try? dataController.viewContext.save()
        self.toolbar.isHidden = true
        
        navigationController?.popViewController(animated: true)
    }
    
    func configureShareOut(isEnabled: Bool){
        shareOUT.isEnabled = isEnabled
    }
    
    func prepareTextField(textField: UITextField, name: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: name,
            attributes:
            [NSAttributedStringKey.foregroundColor: UIColor.white,
             NSAttributedStringKey.strokeWidth : -3.0,
             NSAttributedStringKey.strokeColor: UIColor.black
            ])
        textField.defaultTextAttributes = borrowTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    // MARK: Objects
    @objc func keyboardWillShow(notification: NSNotification) {
        if bottomTextOUT.isFirstResponder {
            view.frame.origin.y = -keyboardHeight(notification: notification)
        }
        
        
    }
    func accessoryView() -> UIView {
        
        let view = UIView()
        view.backgroundColor = .gray
        
        let returnButton = UIButton()
        returnButton.frame = CGRect(x: self.view.frame.width - 80, y: 7, width: 60, height: 30)
        returnButton.setTitle("Return", for: .normal)
        if #available(iOS 13.0, *) {
            returnButton.tintColor = .label
        } else {
            returnButton.tintColor = .white
        }
        returnButton.addTarget(self, action: #selector(BorrowEditorViewController.doneAction), for: .touchUpInside)
        view.addSubview(returnButton)
        
        return view
        
    }
    
    @objc func doneAction() {
        bottomTextOUT.resignFirstResponder()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        resetFrame()
    }
    
}





