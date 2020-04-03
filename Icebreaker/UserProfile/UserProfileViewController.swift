//
//  UserProfileViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 4/3/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import JGProgressHUD
import SDWebImage
import CoreLocation

class UploadProjectImagePickerController: UIImagePickerController{
    var imageButton: UIButton?
}

class UserProfileViewController: UITableViewController, UINavigationControllerDelegate, ScannerViewControllerDelegate,UIImagePickerControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    

    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    var userId: User?
    var user: User?

    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 9
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action:  selector, for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }
    
    @objc func handleSelectPhoto(button: UIButton){
        if userId?.uid == Auth.auth().currentUser?.uid {
            let imagePicker = UploadProjectImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageButton = button
            present(imagePicker, animated: true)
        } else {
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLeftNavigation()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        
        loadUserPhotos()
        setupTapGesture()
        
    }
    
    fileprivate func setupTapGesture() {
          view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
      }
      
      @objc fileprivate func handleTapDismiss() {
          self.view.endEditing(true) // dismisses keyboard
      }
    

    fileprivate func loadUserPhotos(){
        if let imageUrl = userId?.imageUrl1, let url = URL(string: imageUrl) {
        SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil){ (image, _,_,_,_,_) in
            self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
        if let imageUrl = userId?.imageUrl2, let url = URL(string: imageUrl) {
        SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil){ (image, _,_,_,_,_) in
            self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
        if let imageUrl = userId?.imageUrl3, let url = URL(string: imageUrl) {
        SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil){ (image, _,_,_,_,_) in
            self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
}
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return header
        
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Work"
        case 3:
            headerLabel.text = "City"
        case 4:
            headerLabel.text = "School"
        case 5:
            headerLabel.text = "Email"
        case 6:
            headerLabel.text = "Phone"
        case 7:
            headerLabel.text = "Gender"
        default:
            headerLabel.text = "Age"
        }
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
        return 300
        }
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UploadCell(style: .default, reuseIdentifier: nil)
        
        if userId?.uid == Auth.auth().currentUser?.uid {
            cell.isUserInteractionEnabled = true
        } else {
            cell.isUserInteractionEnabled = false
        }
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
            
        case 2:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.work
            cell.textField.addTarget(self, action: #selector(handleWorkChange), for: .editingChanged)
            
        case 3:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.city
            cell.textField.addTarget(self, action: #selector(handleCityChange), for: .editingChanged)
            
        case 4:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.school
            cell.textField.addTarget(self, action: #selector(handleSchoolChange), for: .editingChanged)
            
        case 5:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.email
            cell.textField.addTarget(self, action: #selector(handleEmailChange), for: .editingChanged)
            
        case 6:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.phone
            cell.textField.addTarget(self, action: #selector(handlePhoneChange), for: .editingChanged)
            
        case 7:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.gender
            cell.textField.addTarget(self, action: #selector(handleGenderChange), for: .editingChanged)
            
        default:
            cell.textField.placeholder = ""
            cell.textField.text = userId?.age
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)

        }
        
        return cell
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField){
        self.userId?.name = textField.text ?? ""
    }
    @objc fileprivate func handleWorkChange(textField: UITextField){
        self.userId?.work = textField.text ?? ""
           
    }
    
    @objc fileprivate func handleCityChange(textField: UITextField){
        self.userId?.city = textField.text ?? ""
    }
    
    @objc fileprivate func handleSchoolChange(textField: UITextField){
        self.userId?.school = textField.text ?? ""
    }
    
    @objc fileprivate func handleEmailChange(textField: UITextField){
        self.userId?.email = textField.text ?? ""
    }
    @objc fileprivate func handlePhoneChange(textField: UITextField){
        self.userId?.phone = textField.text ?? ""
    }
    @objc fileprivate func handleGenderChange(textField: UITextField){
        self.userId?.gender = textField.text ?? ""
    }
    @objc fileprivate func handleAgeChange(textField: UITextField){
        self.userId?.age = textField.text ?? ""
    }

    fileprivate func setupLeftNavigation() {
        if userId?.uid == Auth.auth().currentUser?.uid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveUserDetails))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(presentScanner))
        }
    }

    @objc fileprivate func presentScanner(){
        let registrationController = ScannerViewController()
        registrationController.delegate = self
        present(registrationController, animated: true)
    }
    @objc fileprivate func saveUserDetails(){
        self.view.endEditing(true)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let docData: [String: Any] = [
            "uid": uid,
            "name": userId?.name ?? "",
            "work": userId?.work ?? "",
            "city": userId?.city ?? "",
            "school": userId?.school ?? "",
            "email": userId?.email ?? "",
            "phone": userId?.phone ?? "",
            "gender": userId?.gender ?? "",
            "age": userId?.age ?? "",
            "imageUrl1":userId?.imageUrl1 ?? "",
            "imageUrl2":userId?.imageUrl2 ?? "",
            "imageUrl3":userId?.imageUrl3 ?? "",
        ]

        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { (err) in
            if let err = err {
                print(err)
                return
            }
            print("Uploaded")
        }
           self.dismiss(animated: true, completion: {
           print("Dismissal complete")
        })
         
        
    }
    
    func didScanQRCode(code: String) {
        print("Here is the scanned QR Code",code)
        print(code)
        if code == userId?.uid {
            print("User is a match!")
            let uid = Auth.auth().currentUser?.uid ?? ""
            let collection = Firestore.firestore().collection("users").document(uid)
            collection.updateData([
                "contacts": FieldValue.arrayUnion([code])
            ])
            DispatchQueue.main.async {
                self.addFriendSuccess()
                
            }
        } else {
            print("user is not a match")
            DispatchQueue.main.async {
                self.qrCodeError()
                
            }
        }
    }
    
    fileprivate func qrCodeError(){
        let sendMailErrorALert = UIAlertController(title: "Error!", message: "It seems like the code you scanned does not match the user. Please try again!", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorALert.addAction(dismiss)
        self.present(sendMailErrorALert, animated: true, completion: nil)
    }
    fileprivate func addFriendSuccess(){
        let sendMailErrorALert = UIAlertController(title: "Success", message: "You have successfully added \(userId?.name ?? "User") to your contacts.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorALert.addAction(dismiss)
        self.present(sendMailErrorALert, animated: true, completion: nil)
    }
    
    let model = nsfw()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let buffer = selectedImage!.buffer()!
        
        // Predict
        guard let output = try? model.prediction(data: buffer) else {
            fatalError("Unexpected runtime error.")
        }
        
        // Grab the result from prediction
        let proba = output.prob[1].doubleValue
        print(proba)
        if proba < 0.2 {
            let imageButton = (picker as? UploadProjectImagePickerController)?.imageButton
            imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            dismiss(animated: true)
            
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/contractorimages/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else {return}
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Uploading Image"
        hud.show(in: view)
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            hud.dismiss()
            if let err = err{
                print("failed to upload data to storage", err)
                return
            }
            print("finished updating data")
            ref.downloadURL { (url, err) in
                hud.dismiss()
                if let err = err{
                    print("failed to retrive to storage", err)
                    return
                }
                print("finished getting downloard URl", url?.absoluteString ?? "")
                if imageButton == self.image1Button{
                    self.userId?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.userId?.imageUrl2 = url?.absoluteString
                } else {
                    self.userId?.imageUrl3 = url?.absoluteString
                }
            }
        }
        } else {
            print("IMAGE IS NOT APPROPRIATE")
            dismiss(animated: true)
            self.showPhotoError()
        }
    }
    @objc fileprivate func showPhotoError(){
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.error)
        let sendMailErrorALert = UIAlertController(title: "Please select an appropriate photo.", message: "The photo you've chosen is not appropriate.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorALert.addAction(dismiss)
        self.present(sendMailErrorALert, animated: true, completion: nil)
    }


}
extension UIImage {
    
    func buffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        
        let width = 224
        let height = 224
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue:0))
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bitmapContext = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorspace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
        
        bitmapContext.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelBuffer
    }
}


