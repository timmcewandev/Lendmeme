
//  Copyright © 2017 McEwanTech. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import AVFoundation
import BubbleTransition
import FittedSheets
import GoogleMobileAds

class BorrowEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Variables
    let contact = CNMutableContact()
    let borrow: [BorrowInfo]! = nil
    var dataController: DataController!
    var nameOfBorrower: String?
    let transition = BubbleTransition()
    var selectedDate: String?
    
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
    @IBOutlet weak var insertImageContainer: UIStackView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var remindMe: UISwitch!
    @IBOutlet weak var dateSelected: UILabel!
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureShareOut(isEnabled: false)
        prepareTextField(textField: topTextOUT, name: "Add persons name")
        prepareTextField(textField: bottomTextOUT, name: "Add phone")
        prepareTextField(textField: titleTextOUT, name: "Add title")
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
            view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        topTextOUT.resignFirstResponder()
        titleTextOUT.resignFirstResponder()
        bottomTextOUT.resignFirstResponder()
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
        checkCameraPermissions()
    }
    
    @IBAction func cancelBTN(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func share(sender: AnyObject) {
        self.save()
    }
    
    @IBAction func remindMeAction(_ sender: UISwitch) {
        if sender.isOn == true {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController

            self.present(controller, animated: true, completion: nil)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelection" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? ImageViewController {
            }
        }
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
            myPickerController.transitioningDelegate = self
            myPickerController.modalPresentationCapturesStatusBarAppearance = true
            myPickerController.modalPresentationStyle = .custom
            present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate for Bubble
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = cameraButton.center
        transition.bubbleColor = UIColor.black
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = cameraButton.center
        transition.bubbleColor = UIColor.black
        return transition
    }
    
    // MARK: - End of Bubble Animation
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            insertImageContainer.isHidden = true
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
        
        if textField == topTextOUT {
            let status = CNContactStore.authorizationStatus(for: .contacts)
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
                        alert.addAction(UIAlertAction(title: "Sure", style: .default, handler: {[weak self] _ in
                            let phoneNumber = phoneNumberFound.replacingOccurrences(of: "+1", with: "")
                            self?.bottomTextOUT.text = phoneNumber
                            self?.checkIfNextTextFieldIsEmpty(focusedTextField: (self?.topTextOUT)!, toNextTextField: (self?.titleTextOUT)!)
                            
                        }))
                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] _ in
                            self?.checkIfNextTextFieldIsEmpty(focusedTextField: (self?.topTextOUT)!, toNextTextField: (self?.titleTextOUT)!)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch {
                print("Failed to fetch contact, error: \(error)")
            }
        }
        checkIfNextTextFieldIsEmpty(focusedTextField: titleTextOUT, toNextTextField: topTextOUT)
        checkIfNextTextFieldIsEmpty(focusedTextField: topTextOUT, toNextTextField: titleTextOUT)
        
        resetFrame()
        return false
    }
    
    func checkIfNextTextFieldIsEmpty (focusedTextField: UITextField, toNextTextField: UITextField) {
        if focusedTextField.returnKeyType == .next && toNextTextField.text?.isEmpty == true {
            focusedTextField.resignFirstResponder()
            toNextTextField.becomeFirstResponder()
        }
    }
    
    func generateMemedImage() -> UIImage {
        if topTextOUT.text == "" {
            topTextOUT.isHidden = true
        }
        if bottomTextOUT.text == "" {
            bottomTextOUT.isHidden = true
        }
        if titleTextOUT.text == "" {
            titleTextOUT.isHidden = true
        }
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        topTextOUT.isHidden = false
        bottomTextOUT.isHidden = false
        titleTextOUT.isHidden = false
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
    
    func checkCameraPermissions() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            camera()
        case .denied:
            alertPromptToAllowCameraAccessViaSetting()
        default:
            camera()
        }
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(title: "", message: "Flip the switch on camera. So you can take pictures of items. 😀", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { (alert) -> Void in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        present(alert, animated: true)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == bottomTextOUT {
            guard let text = bottomTextOUT.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            bottomTextOUT.text = formattedNumber(number: newString)
            return false
        }
        return true
    }
    
    func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    @objc func doneAction() {
        bottomTextOUT.resignFirstResponder()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        resetFrame()
    }
    
}





