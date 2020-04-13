//
//  RegistrationViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import MessageUI
import WebKit
import Foundation

protocol RegistrationViewControllerDelegate {
    func didFinishUserSigningIn()
}

class RegistrationViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    lazy var LogoButton = self.createButton(image:#imageLiteral(resourceName: "splashScreenLogo") , selector: #selector(handleEmailButton))
    
    var delegate: LoginViewControllerDelegate?
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 44)
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.backgroundColor = .white
        tf.autocapitalizationType = .none
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()

    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 44)
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let confirmpasswordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 44)
        tf.placeholder = "Confirm Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let nameTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 44)
        tf.placeholder = "Full Name"
        tf.backgroundColor = .white
        tf.autocapitalizationType = .none
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()

    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let returnHome: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Return", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(returnToHome), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        setupLayout()
        setupNotificationObservers()
        setupTapGesture()
        
        
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
    
    
    
    @objc fileprivate func handleTextChange(textField: UITextField){
        if textField == emailTextField{
            registrationViewModel.email = textField.text
        } else if textField == passwordTextField{
            registrationViewModel.password = textField.text
        } else if textField == confirmpasswordTextField {
            registrationViewModel.confirmpassword = textField.text
        } else {
            registrationViewModel.name = textField.text
        }
        
    }
    

    
    let hud = JGProgressHUD(style: .dark)
    let registeringHUD = JGProgressHUD(style: .light)

    @objc fileprivate func handleRegister(){
        self.view.endEditing(true)

        if passwordTextField.text == confirmpasswordTextField.text {
            hud.textLabel.text = "Registering"
            hud.show(in: view)
            registrationViewModel.performRegistration{ [weak self] (err) in
                if let err = err {
                    self?.showHUDWithError(error: err)
                    self!.hud.dismiss()
                    return
                }
                self!.hud.dismiss()
                self?.dismiss(animated: true, completion: nil)
                }
        } else {
            self.showPasswordError()
            
        }
    }
    
    @objc fileprivate func showPasswordError(){
          let sendMailErrorALert = UIAlertController(title: "Password Error", message: "Passwords do not match.", preferredStyle: .alert)
          let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
          sendMailErrorALert.addAction(dismiss)
          self.present(sendMailErrorALert, animated: true, completion: nil)
      }
    

    @objc fileprivate func handleEmailButton(){
        print("Emailing Contractor")
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            //This is the mailing address
            mail.setToRecipients(["sincfounders@gmail.com"])
            //This contains the body message
            //mail.setMessageBody("<p>Could you please give me a quote on a 10x30 deck?</p>", isHTML: true)
            present(mail, animated: true)
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
        func showMailError(){
            let sendMailErrorALert = UIAlertController(title: "Could not send email", message: "This device does not support email", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
            sendMailErrorALert.addAction(dismiss)
            self.present(sendMailErrorALert, animated: true, completion: nil)
        }

    }
    
    //creates an error message when user inputs incorrect information
    fileprivate func showHUDWithError(error: Error){
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Input Correct Email"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2)
        
    }

    let registrationViewModel = RegistrationViewModel()
    
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true) // dismisses keyboard
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self) // you'll have a retain cycle
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
        let bottomSpace = view.frame.height - stackView.frame.origin.y - stackView.frame.height
        print(bottomSpace)
        
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    @objc fileprivate func returnToHome() {
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    lazy var stackView = UIStackView(arrangedSubviews: [
        LogoButton,
        nameTextField,
        emailTextField,
        passwordTextField,
        confirmpasswordTextField,
        registerButton,
        returnHome
        ])
    
    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
