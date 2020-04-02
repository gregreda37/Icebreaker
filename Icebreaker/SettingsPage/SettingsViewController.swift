//
//  SettingsViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import Firebase
import LBTATools
import JGProgressHUD
import SDWebImage
import JGProgressHUD

class SettingsViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,LoginViewControllerDelegate,UITextFieldDelegate {
    

    var profileImage: String?
    var profileImageTapped: Double?
    var user: User?
    
    lazy var forgotPasswordButton = self.createButton(image:#imageLiteral(resourceName: "forgotPasswordButton") , selector: #selector(handleSubmission))
    
    let image1Button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "GregFace").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Profile", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(saveInfoToFirestore), for: .touchUpInside)
        return button
    }()
    
    let signoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)

        return tf
    }()
    
    let majorTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Major"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let yearTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Year "
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let scrollView: UIScrollView = {
         let v = UIScrollView()
         v.translatesAutoresizingMaskIntoConstraints = false
         v.backgroundColor = .white
         return v
     }()
    
    let labelTwo: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var vStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            nameTextField,
            emailTextField,
            yearTextField,
            majorTextField,
            updateButton,
            signoutButton,
            forgotPasswordButton])
        sv.axis = .vertical
        sv.spacing = 8
        sv.distribution = .fillEqually
        return sv
    }()
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(scrollView)

        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true

        scrollView.addSubview(image1Button)
        
        image1Button.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        image1Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true


        nameTextField.delegate = self
        
        scrollView.addSubview(vStackView)
        vStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.0).isActive = true
        vStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.0).isActive = true

        vStackView.anchor(top: image1Button.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 900)
        
        scrollView.addSubview(labelTwo)

        // constrain labelTwo at 400-pts from the left
        labelTwo.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 400.0).isActive = true

        // constrain labelTwo at 1000-pts from the top
        labelTwo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 1000).isActive = true

        // constrain labelTwo to right & bottom with 16-pts padding
        labelTwo.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 16.0).isActive = true
        labelTwo.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 16.0).isActive = true
        


        fetchCurrentUser()
        setupTapGesture()
    }
    

    
    let hud = JGProgressHUD(style: .light)
    let registeringHUD = JGProgressHUD(style: .light)
    

    
    fileprivate func fetchCurrentUser(){
        //fetch current user
        guard let uid =  Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
            self.loadUserPhotos()
            self.loadText()
            
            
        }
    }
    
    fileprivate func loadUserPhotos(){
            if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil){ (image, _,_,_,_,_) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                self.image1Button.layer.cornerRadius = 70
            }
        }
    }
    
    fileprivate func loadText(){
        emailTextField.text = user?.email
        nameTextField.text = user?.name
        majorTextField.text = user?.major
        yearTextField.text = user?.year
        
    }
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image1Button.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image1Button.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        image1Button.layer.cornerRadius = image1Button.frame.width/2
        image1Button.layer.masksToBounds = true
        image1Button.layer.borderColor = UIColor.white.cgColor
        image1Button.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        
        guard let image = self.image1Button.imageView?.image else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        
        ref.putData(imageData, metadata: nil, completion: { (_, err) in
            
            if let err = err {
                print(err)
                return // bail
            }
            
            print("Finished uploading image to storage")
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    print(err)
                    return
                }
                
                let imageUrl = url?.absoluteString ?? ""
                self.savePhotoToFirestore(imageUrl: imageUrl)
            })
        })
    }
    

    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true) // dismisses keyboard
    }
    

    fileprivate func savePhotoToFirestore(imageUrl: String) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String : Any] = [
            "imageUrl1": imageUrl,
            "major": majorTextField.text ?? "",
            "year": yearTextField.text ?? "",
            "uid": uid
            
            ]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { (err) in
            if let err = err {
                print(err)
                return
            }
            print("Uploaded")
        }
    }
    
    @objc fileprivate func saveInfoToFirestore(){
        self.view.endEditing(true)
        hud.textLabel.text = "Updating"
        hud.show(in: view)
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String : Any] = [
            "username": nameTextField.text ?? "",
            "major": majorTextField.text ?? "",
            "year": yearTextField.text ?? "",
            "uid": uid
            ]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { (err) in
            if let err = err {
                print(err)
                self.showHUDWithError(error: err)
                return
            }
            print("Uploaded")
        }
        self.hud.dismiss()
        fetchCurrentUser()
    }
    fileprivate func showHUDWithError(error: Error){
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Information failed to upload"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2)
        
    }
    
    @objc fileprivate func logout(){
        try? Auth.auth().signOut()
        print("User Signed Out")
        let vc = LoginViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        self.present(vc, animated: true, completion: nil)
        
    }
    @objc fileprivate func handleSubmission() {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (err) in
            if let err = err {
                print("Failed to fetch user:", err)
                self.showPasswordError()
                return
            } else {
                print("Password Reset")
                self.showPasswordNotification()
                
            }
        }


    }
    @objc fileprivate func showPasswordNotification(){
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.error)
        let showPasswordNotification = UIAlertController(title: "Sent", message: "Please check \(emailTextField.text!) to reset your password", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        showPasswordNotification.addAction(dismiss)
        self.present(showPasswordNotification, animated: true, completion: nil)
        
    }
    
    @objc fileprivate func showPasswordError(){
          let sendMailErrorALert = UIAlertController(title: "Account Error", message: "Please double check your email", preferredStyle: .alert)
          let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
          sendMailErrorALert.addAction(dismiss)
          self.present(sendMailErrorALert, animated: true, completion: nil)
      }

    @objc fileprivate func handleNothing(){
        print("Button tapped")
        self.dismiss(animated: true, completion: nil)
    }
    
    func didFinishLoggingIn() {
        
    }
    
    private func setupRemainingNavItems(){
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "settingsHeader"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = titleImageView
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }
    
}

