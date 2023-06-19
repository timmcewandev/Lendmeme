
//  Copyright © 2017 McEwanTech. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import AVFoundation
import BubbleTransition
import FittedSheets

class BorrowEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Variables
    var dataController: DataController!
    var nameOfBorrower: String?
    let transition = BubbleTransition()
    var category: String?
    var imageInfo: [[ImageInfo]] = [[]]
    var selectedBorrowedInfo: ImageInfo?
    var onEdit = false
    var datasource = Constants.Categories.gatherCategories()
    
    // MARK: Outlets
//    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareOUT: UIBarButtonItem!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var titleOfItemTextField: UITextField!
    @IBOutlet weak var nameOfBorrowerTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelOut: UIBarButtonItem!
    @IBOutlet weak var insertImageContainer: UIStackView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var categoryLabel: UIButton!
    
    @IBOutlet weak var toobarView: UIToolbar!
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        fetchImageInfo()
        configureTapGestureForDismiss()
        toolbar.layer.cornerRadius = 30
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        titleOfItemTextField.resignFirstResponder()
        nameOfBorrowerTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
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
        self.selectedBorrowedInfo = nil
        self.onEdit = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func share(sender: AnyObject) {
        self.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelection" {
            if let destVC = segue.destination as? UINavigationController,
                let _ = destVC.topViewController as? ImageViewController {
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
    
    func configureTapGestureForDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func configure() {
        configureShareOut(isEnabled: false)
        prepareTextField(textField: titleOfItemTextField, name: Constants.TextFieldNames.itemTitle)
        prepareTextField(textField: nameOfBorrowerTextField, name: Constants.TextFieldNames.nameOfPersonBorrowing)
        prepareTextField(textField: phoneNumberTextField, name: Constants.TextFieldNames.phoneNumberText)
        self.tabBarController?.tabBar.isHidden = true
        phoneNumberTextField.inputAccessoryView = accessoryView()
        phoneNumberTextField.inputAccessoryView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        view.addSubview(phoneNumberTextField)
        
        if onEdit == true {
            phoneNumberTextField.text = selectedBorrowedInfo?.bottomInfo
            nameOfBorrowerTextField.text = selectedBorrowedInfo?.titleinfo
            titleOfItemTextField.text = selectedBorrowedInfo?.nameOfPersonBorrowing
            
            if let memeImageData = selectedBorrowedInfo?.originalImage {
                self.imageView.image = UIImage(data: memeImageData)
                //                self.imageView.image?.fixedOrientation()
                configureShareOut(isEnabled: true)
            }else {
                configureShareOut(isEnabled: false)
            }
            
        }
    }
    
    func fetchImageInfo() {
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            if result.count == 0 {
                self.navigationController?.isNavigationBarHidden = true
                configureCancelOut(isEnabled: false)
            }
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
            imageView.image = pickedImage.fixedOrientation()
            insertImageContainer.isHidden = true
            self.configureShareOut(isEnabled: true)
        }
        dismiss(animated: true, completion: nil)
    }
    func resetFrame() {
        self.view.frame.origin.y = 0
    }
    
    func keyboardHeight(notification: NSNotification) -> CGFloat {
        if let rect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            return rect.cgRectValue.height
        } else {
            return CGFloat(0)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if textField == titleOfItemTextField {
            _ = CNContactStore.authorizationStatus(for: .contacts)
            let nameMe = self.titleOfItemTextField.text
            let nameProperCapitalization = (nameMe?.lowercased().capitalized) ?? ""
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
                            guard let self = self else {return}
                            self.titleOfItemTextField.text = contacts[0].givenName + " " + contacts[0].familyName
                            let phoneNumber = phoneNumberFound.replacingOccurrences(of: "+1", with: "")
                            self.phoneNumberTextField.text = phoneNumber
                            self.checkIfNextTextFieldIsEmpty(focusedTextField: self.titleOfItemTextField, toNextTextField: self.nameOfBorrowerTextField)
                            
                        }))
                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] _ in
                            guard let self = self else {return}
                            self.checkIfNextTextFieldIsEmpty(focusedTextField: self.titleOfItemTextField, toNextTextField: self.nameOfBorrowerTextField)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        checkIfNextTextFieldIsEmpty(focusedTextField: nameOfBorrowerTextField, toNextTextField: titleOfItemTextField)
        checkIfNextTextFieldIsEmpty(focusedTextField: titleOfItemTextField, toNextTextField: nameOfBorrowerTextField)
        
        resetFrame()
        return false
    }
    
    func checkIfNextTextFieldIsEmpty (focusedTextField: UITextField, toNextTextField: UITextField) {
        if focusedTextField.returnKeyType == .next && toNextTextField.text?.isEmpty == true {
            focusedTextField.resignFirstResponder()
            toNextTextField.becomeFirstResponder()
        }
    }
    
    func takeScreenshot() -> UIImage? {
        self.navigationController?.isNavigationBarHidden = true
        categoryLabel.isHidden = true
        var screenshotImage :UIImage?
        let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        let layer = keyWindow?.layer
        let scale = UIScreen.main.scale.binade
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer?.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
    }
    
    func save() {
        if onEdit == true {
            self.insertImageContainer.isHidden = true
            guard let memedImage = takeScreenshot() else { return }
            guard let originalImage = imageView.image else { return }
            var phone = phoneNumberTextField.text
            phone = phone?.replacingOccurrences(of: "[ |()-]", with: "", options: [.regularExpression])
            
            selectedBorrowedInfo?.titleinfo = nameOfBorrowerTextField.text
            selectedBorrowedInfo?.nameOfPersonBorrowing = titleOfItemTextField.text
            selectedBorrowedInfo?.bottomInfo = phone
            selectedBorrowedInfo?.originalImage = UIImagePNGRepresentation(originalImage)
            
            selectedBorrowedInfo?.imageData = UIImagePNGRepresentation(memedImage)
            onEdit = false
            selectedBorrowedInfo = nil
            try? self.dataController.viewContext.save()
            self.toolbar.isHidden = true
            self.dataController.viewContext.refreshAllObjects()
        } else {
            if titleOfItemTextField.text == "" || nameOfBorrowerTextField.text == "" || phoneNumberTextField.text == "" {
                    for i in [titleOfItemTextField, nameOfBorrowerTextField, phoneNumberTextField] {
                        if i?.text == "" {
                            i?.layer.borderWidth = 2
                            i?.layer.borderColor = UIColor.systemPink.cgColor
                        } else {
                            i?.layer.borderWidth = 0
                            i?.layer.borderColor = UIColor.label.cgColor
                        }
                    }
                let alert = UIAlertController(title: "", message: "Missing information in textfield", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            for i in [titleOfItemTextField, nameOfBorrowerTextField, phoneNumberTextField] {
                if i?.text != "" {
                        i?.layer.borderWidth = 0
                    i?.layer.borderColor = UIColor.label.cgColor
                }
            }
            toolbar.isHidden = true
            guard let memedImage = takeScreenshot() else { return }
            guard let originalImage = imageView.image else { return }
            var phone = phoneNumberTextField.text
            phone = phone?.replacingOccurrences(of: "[ |()-]", with: "", options: [.regularExpression])
            let borrowInfo = BorrowInfo(topString: self.titleOfItemTextField.text ?? "None", bottomString: phone, titleString: nameOfBorrowerTextField.text ?? "", originalImage: originalImage, borrowImage: memedImage, hasBeenReturned: false, timeHasExpired: false)
            
            let getImageInfo = ImageInfo(context: dataController.viewContext)
            getImageInfo.imageData = UIImagePNGRepresentation(borrowInfo.borrowImage)
            
            getImageInfo.nameOfPersonBorrowing = self.titleOfItemTextField.text ?? "None"
            getImageInfo.titleinfo = borrowInfo.titleString
            getImageInfo.bottomInfo = borrowInfo.bottomString
            if let selectedCategpry = category {
                getImageInfo.category = selectedCategpry
            }
            getImageInfo.originalImage = UIImagePNGRepresentation(borrowInfo.originalImage)
            getImageInfo.creationDate = Date()
            getImageInfo.reminderDate = nil
            getImageInfo.hasBeenReturned = false
            getImageInfo.timeHasExpired = false
            setDueDateTimeAndDate(getImageInfo: getImageInfo)
            try? dataController.viewContext.save()
            self.toolbar.isHidden = true
        }
        navigationController?.popViewController(animated: true)
    }
    
    func setDueDateTimeAndDate(getImageInfo: ImageInfo) {
        var date = Date()
        date = Calendar.current.date(bySettingHour: 11, minute: 30, second: 00, of: date)!
        let dueDate = Calendar.current.date(byAdding: .day, value: 7, to: date)
        getImageInfo.reminderDate = dueDate
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.scheduleNotification(at: getImageInfo.reminderDate!, name: getImageInfo.titleinfo ?? "", memedImage: getImageInfo)
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
        textField.textAlignment = .center
        textField.delegate = self
        textField.placeholder = name
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
        if phoneNumberTextField.isFirstResponder {
            view.frame.origin.y = -keyboardHeight(notification: notification)
        }
        
        
    }
    func accessoryView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBlue
        
        let doneButton = UIButton()
        doneButton.frame = CGRect(x: self.view.frame.width - 80, y: 7, width: 60, height: 30)
        doneButton.setTitle("Done", for: .normal)
        doneButton.tintColor = .label
        doneButton.addTarget(self, action: #selector(BorrowEditorViewController.doneAction), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        return view
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberTextField {
            guard let text = phoneNumberTextField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            phoneNumberTextField.text = formattedNumber(number: newString)
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
        phoneNumberTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        resetFrame()
    }
}


extension UIImage {
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
