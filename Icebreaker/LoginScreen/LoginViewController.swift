//
//  LoginViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import JGProgressHUD
import LBTATools
import Firebase

protocol LoginViewControllerDelegate {
    func didFinishLoggingIn()
}

class LoginViewController: UIViewController {
    
    var delegate: LoginViewControllerDelegate?
    
    lazy var LogoButton = self.createButton(image:#imageLiteral(resourceName: "splashScreenLogo") , selector: #selector(handleSignUp))
    //lazy var spacer = self.createButton(image:#imageLiteral(resourceName: "spacer") , selector: #selector(handleSignUp))
    lazy var forgotPasswordButton = self.createButton(image:#imageLiteral(resourceName: "forgotPasswordButton") , selector: #selector(handlePasswordReset))
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "grayBox")
        return iv
    }()
    
    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.layer.masksToBounds = false
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        tf.layer.masksToBounds = false
        tf.layer.shadowRadius = 3.0
        tf.layer.shadowOpacity = 0.2
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let eventRegister: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register an Event", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleEventRegister), for: .touchUpInside)
        return button
    }()

    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            LogoButton,
            //spacer,
            emailTextField,
            passwordTextField,
            loginButton,
            signupButton,
            eventRegister,
            forgotPasswordButton,
            ])
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()

    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == emailTextField {
            loginViewModel.email = textField.text
        } else {
            loginViewModel.password = textField.text
        }
    }
    
    @objc fileprivate func handleLogin() {
        self.view.endEditing(true)
        loginViewModel.performLogin { (err) in
            self.loginHUD.dismiss()
            if let err = err {
                print("Failed to log in:", err)
                self.showPasswordError()
                return
            }
            
            print("Logged in successfully")
            self.presentHomeController()
        }
    }
    
    @objc fileprivate func showPasswordError(){
          let sendMailErrorALert = UIAlertController(title: "Account Error", message: "Please double check your email and password ", preferredStyle: .alert)
          let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
          sendMailErrorALert.addAction(dismiss)
          self.present(sendMailErrorALert, animated: true, completion: nil)
      }
    
    func presentHomeController(){
            self.dismiss(animated: true, completion: nil)
    }

    
    
    @objc fileprivate func handleSignUp() {
        let loginController = RegistrationViewController()
        loginController.delegate = delegate
        self.view.endEditing(true)
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc fileprivate func handleEventRegister() {
        let loginController = RegisterEventViewController()
        self.view.endEditing(true)
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc fileprivate func handlePasswordReset() {
        let registrationController = ForgotPasswordViewController()
        present(registrationController, animated: true)
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        setupGradientLayer()
        setupTapGesture()
        setupLayout()
        setupBindables()
        setupNotificationObservers()
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss(){
        self.view.endEditing(true) // dismisses keyboard
    }
    
    fileprivate let loginViewModel = LoginViewModel()
    
    fileprivate let loginHUD = JGProgressHUD(style: .dark)
    
    fileprivate func setupNotificationObservers() {
          NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
      }
    
    
    fileprivate func setupBindables() {
        loginViewModel.isFormValid.bind { [unowned self] (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self.loginButton.isEnabled = isFormValid
            self.loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : .lightGray
            self.loginButton.setTitleColor(isFormValid ? .white : .black, for: .normal)
        }
        loginViewModel.isLoggingIn.bind { [unowned self] (isRegistering) in
            if isRegistering == true {
                self.loginHUD.textLabel.text = "Loading"
                self.loginHUD.show(in: self.view)
            } else {
                self.loginHUD.dismiss()
            }
        }
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

    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(verticalStackView)
        
        
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  
        
//        view.addSubview(horizontalStackView)
//        horizontalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 20))
    }
}
