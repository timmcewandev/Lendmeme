
//  Copyright © 2017 McEwanTech. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts

class BorrowEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    let contact = CNMutableContact()
    let borrow: [BorrowInfo]! = nil
    var dataController: DataController! = nil
    var nameOfBorrower: String?

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
    @IBOutlet weak var titleTextOUT: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelOut: UIBarButtonItem!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureShareOut(isEnabled: false)
        prepareTextField(textField: topTextOUT, name: " Borrowers name")
        prepareTextField(textField: bottomTextOUT, name: "Phone number")
        prepareTextField(textField: titleTextOUT, name: "Item title")
        self.tabBarController?.tabBar.isHidden = true
        bottomTextOUT.inputAccessoryView = accessoryView()
        bottomTextOUT.inputAccessoryView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        view.addSubview(bottomTextOUT)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            if result.count == 0 {
                self.navigationController?.isNavigationBarHidden = true
                configureCancelOut(isEnabled: false)
            }
        }
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
         let nameMe = self.topTextOUT.text
        let nameProperCapitalization = (nameMe?.lowercased().capitalized)!
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let store = CNContactStore()
        nameOfBorrower = nameProperCapitalization
        do {
            let predicate = CNContact.predicateForContacts(matchingName: nameProperCapitalization)
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            if !contacts.isEmpty == true {
                if !contacts[0].phoneNumbers.isEmpty == true {
                    let phoneNumberFound = contacts[0].phoneNumbers[0].value.stringValue
                    let alert = UIAlertController(title: "We found a phone number for \(contacts[0].givenName) \(contacts[0].familyName)", message: "Would you like to use it?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Sure", style: .default, handler: {[weak self] _ in
                        let phoneNumber = phoneNumberFound.replacingOccurrences(of: "+1", with: "")
                        self?.bottomTextOUT.text = phoneNumber
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } catch {
            print("Failed to fetch contact, error: \(error)")
        }
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
        if titleTextOUT.text == "" {
            titleTextOUT.placeholder = ""
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
        let borrowInfo = BorrowInfo(topString: topTextOUT.text!, bottomString: bottomTextOUT.text!, titleString: titleTextOUT.text!, originalImage: imageView.image!, borrowImage: memedImage, hasBeenReturned: false)

        let getImageInfo = ImageInfo(context: dataController.viewContext)
        getImageInfo.imageData = UIImagePNGRepresentation(borrowInfo.borrowImage)
        if let topName = nameOfBorrower {
            getImageInfo.topInfo = topName
        } else {
           getImageInfo.topInfo = borrowInfo.topString
        }
        getImageInfo.titleinfo = borrowInfo.titleString
        getImageInfo.bottomInfo = borrowInfo.bottomString
        getImageInfo.creationDate = Date()
        getImageInfo.hasBeenReturned = false
        try? dataController.viewContext.save()
        self.toolbar.isHidden = true
        
        navigationController?.popViewController(animated: true)
    }
    func configureCancelOut(isEnabled: Bool){
        cancelOut.isEnabled = isEnabled
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





