//
//  ForgotPasswordViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    lazy var LogoButton = self.createButton(image:#imageLiteral(resourceName: "splashScreenLogo") , selector: #selector(handleNothing))

    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.layer.masksToBounds = false
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        return tf
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgb(red: 248, green: 149, blue: 19)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleSubmission), for: .touchUpInside)
        return button
    }()
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            LogoButton,
            emailTextField,
            submitButton,
            ])
        sv.axis = .vertical
        sv.spacing = 12
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
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        setupGradientLayer()
        view.addSubview(verticalStackView)
    
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        setupTapGesture()
        setupNotificationObservers()
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
        gradientLayer.locations = [0, 3.9]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
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
        showPasswordNotification.addAction(UIAlertAction(title: "Yes", style: .default, handler:{(_: UIAlertAction!) in
            self.handleNothing()
        }))
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
    

}

