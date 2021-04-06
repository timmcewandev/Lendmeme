
//  Copyright © 2017 McEwanTech. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import Contacts
import AVFoundation
import BubbleTransition
import FittedSheets
//import GoogleMobileAds

class BorrowEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Variables
    var dataController: DataController!
    var nameOfBorrower: String?
    let transition = BubbleTransition()
    var category: String?
    //    var interstitial: GADInterstitial!
    var imageInfo: [ImageInfo] = []
//    let borrowTextAttributes: [String : Any] = [
//        NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
//        NSAttributedStringKey.strokeWidth.rawValue : -2.2,
//        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white
//    ]
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
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        configureShareOut(isEnabled: false)
        prepareTextField(textField: titleOfItemTextField, name: Constants.TextFieldNames.itemTitle)
        prepareTextField(textField: nameOfBorrowerTextField, name: Constants.TextFieldNames.nameOfPersonBorrowing)
        prepareTextField(textField: phoneNumberTextField, name: Constants.TextFieldNames.phoneNumberText)
        
        self.tabBarController?.tabBar.isHidden = true
        phoneNumberTextField.inputAccessoryView = accessoryView()
        phoneNumberTextField.inputAccessoryView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        view.addSubview(phoneNumberTextField)
        //        bannerView.adUnitID = "ca-app-pub-6335247657896931/5485024801"
        //        bannerView.rootViewController = self
        //        bannerView.load(GADRequest())
        //        bannerView.delegate = self
        //
        //        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6335247657896931/9991246021")
        //        let request = GADRequest()
        //        interstitial.load(request)
        
        let returnButtonForPhoneNumber = UIButton(frame:CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        returnButtonForPhoneNumber.backgroundColor = #colorLiteral(red: 0.9815835357, green: 0.632611692, blue: 0.1478855908, alpha: 1)
        returnButtonForPhoneNumber.setTitle("Return", for: .normal)
        returnButtonForPhoneNumber.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        returnButtonForPhoneNumber.addTarget(self, action: #selector(BorrowEditorViewController.doneAction), for: .touchUpInside)
        phoneNumberTextField.inputAccessoryView = returnButtonForPhoneNumber
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        let fetchRequest: NSFetchRequest<ImageInfo> = ImageInfo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Constants.CoreData.creationDate, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest){
            if result.count == 0 {
                self.navigationController?.isNavigationBarHidden = true
                configureCancelOut(isEnabled: false)
            }
            imageInfo = result
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func share(sender: AnyObject) {
        //        if imageInfo.count > 1 {
        //            let firstNum = arc4random() % 5
        //            let secondNum = arc4random() % 5
        //            if firstNum == secondNum {
        //                if (interstitial.isReady) {
        //                    interstitial.present(fromRootViewController: self)
        //                }
        //            }
        //        }
        self.save()
    }
    
    @IBAction func addCategoryAction(_ sender: UIButton) {
        phoneNumberTextField.isHidden = true
        pickerView.isHidden = false
        
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
        let layer = UIApplication.shared.keyWindow?.layer
        let scale = UIScreen.main.scale.binade
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer?.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
    }
    
    func save() {
        
        if titleOfItemTextField.text == "" || nameOfBorrowerTextField.text == "" || phoneNumberTextField.text == "" {
            let alert = UIAlertController(title: "", message: "Missing information in textfield", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        toolbar.isHidden = true
        guard let memedImage = takeScreenshot() else { return }
        guard let originalImage = imageView.image else { return }
        let borrowInfo = BorrowInfo(topString: self.titleOfItemTextField.text ?? "None", bottomString: phoneNumberTextField.text ?? "", titleString: nameOfBorrowerTextField.text ?? "", originalImage: originalImage, borrowImage: memedImage, hasBeenReturned: false)
        
        let getImageInfo = ImageInfo(context: dataController.viewContext)
        getImageInfo.imageData = UIImagePNGRepresentation(borrowInfo.borrowImage)
        getImageInfo.topInfo = self.titleOfItemTextField.text ?? "None"
        getImageInfo.titleinfo = borrowInfo.titleString
        getImageInfo.bottomInfo = borrowInfo.bottomString
        if let selectedCategpry = category {
            getImageInfo.category = selectedCategpry
        }
        getImageInfo.creationDate = Date()
        getImageInfo.reminderDate = nil
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
        if phoneNumberTextField.isFirstResponder {
            view.frame.origin.y = -keyboardHeight(notification: notification)
        }
        
        
    }
    func accessoryView() -> UIView {
        
        let view = UIView()
        view.backgroundColor = .gray
        
        let returnButton = UIButton()
        returnButton.frame = CGRect(x: self.view.frame.width - 80, y: 7, width: 60, height: 30)
        returnButton.setTitle(Constants.CommandListText.returnText, for: .normal)
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

extension BorrowEditorViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datasource[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let title = self.datasource[row]
            self.categoryLabel.setTitle("Category: \(title)", for: .normal)
            self.category = title
            self.phoneNumberTextField.isHidden = true
            if #available(iOS 13.0, *) {
                self.categoryLabel.tintColor = UIColor.label
            }
            self.pickerView.isHidden = true
            self.categoryLabel.backgroundColor = UIColor.white
            self.phoneNumberTextField.isHidden = false
        }


    }
}

//extension BorrowEditorViewController: GADBannerViewDelegate {
//    private func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        print("Recieved ad")
//    }
//
//    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        print(error)
//    }
//}





