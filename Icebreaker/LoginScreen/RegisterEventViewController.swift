//
//  RegisterEventViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 4/2/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import Firebase

class RegisterEventViewController: UIViewController {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "grayBox")
        return iv
    }()
    
    let eventRegisterTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter event Title"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.layer.masksToBounds = false
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        return tf
    }()
    
    let registerEvent: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register Event", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleEvent), for: .touchUpInside)
        return button
    }()
    
    let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Return", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleReturn), for: .touchUpInside)
        return button
    }()
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            eventRegisterTextField,
            registerEvent,
            returnButton
            ])
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
      
        navigationController?.isNavigationBarHidden = true
        view.addSubview(profileImageView)

        profileImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        
        setupTapGesture()
        setupNotificationObservers()

        // Do any additional setup after loading the view.
        
    }
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss(){
        self.view.endEditing(true) // dismisses keyboard
    }

    fileprivate func setupNotificationObservers() {
          NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
      }

    @objc fileprivate func handleKeyboardHide() {
           UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
               self.view.transform = .identity
           })
       }
       
       @objc fileprivate func handleKeyboardShow(notification: Notification) {
           // how to figure out how tall the keyboard actually is
           guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
           let keyboardFrame = value.cgRectValue
           print(keyboardFrame)
           
           // let's try to figure out how tall the gap is from the register button to the bottom of the screen
           let bottomSpace = view.frame.height - verticalStackView.frame.origin.y - verticalStackView.frame.height
           print(bottomSpace)
           
           let difference = keyboardFrame.height - bottomSpace
           self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
       }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.984911859, green: 0.622210145, blue: 0.07997336239, alpha: 1)
        let bottomColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 3.5]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }

    @objc fileprivate func handleEvent(){
        let image = generateQRCode(from: eventRegisterTextField.text ?? "")
        profileImageView.image = image
        let docData: [String : Any] = [
            "eventTitle": eventRegisterTextField.text ?? ""

        ]
        
        Firestore.firestore().collection("events").addDocument(data: docData) { (err) in
            if let err = err {
                print(err)
                return
            }
        }

    }
    
    @objc fileprivate func handleReturn(){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
        
    }
    
    fileprivate func savePhotoToCamera(){
        UIGraphicsBeginImageContext(profileImageView.frame.size)
        profileImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        UIImageWriteToSavedPhotosAlbum(output!, nil, nil, nil)

        let alert = UIAlertController(title: "Image Saved", message: "Your QR code is saved to Camera Roll", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)

        
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

}
