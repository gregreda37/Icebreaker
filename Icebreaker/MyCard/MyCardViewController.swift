//
//  MyCardViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 4/3/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import Firebase

protocol MyCardViewControllerDelegate {
    func pushSettingsController()
}

class MyCardViewController: UIViewController {
    
    var delegate: MyCardViewControllerDelegate?
    
    lazy var logoutButton = self.createButton(image:#imageLiteral(resourceName: "logoutButton") , selector: #selector(handleLogout))
    
    func loadImage(imageUrl1: String){
        profileImageView.loadImage(urlString: imageUrl1)
        
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.image = UIImage(named: "grayBox")
        return iv
    }()

    let orangeImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        return iv
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.text = ""
        tf.isUserInteractionEnabled = false
        tf.textColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        tf.font = UIFont.boldSystemFont(ofSize: 24.0)
        tf.contentMode = .scaleAspectFill
        tf.clipsToBounds = true
        return tf
        
    }()
    
    let qrCodeView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "grayBox")
        return iv
    }()
    
    let backgroundView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        return iv
    }()
    
    let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Return", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(returnButtonClicked), for: .touchUpInside)
        return button
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
        return button
    }()

    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    
    lazy var hStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            returnButton,
            editButton,
            ])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 2
        sv.distribution = .fillEqually
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        view.addSubview(backgroundView)
        backgroundView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 400)
        backgroundView.layer.cornerRadius = 6
        backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(qrCodeView)
        
        qrCodeView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 200, height: 200)
        qrCodeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qrCodeView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        qrCodeView.layer.cornerRadius = 12
        view.addSubview(orangeImageView)
        view.addSubview(profileImageView)
        
        orangeImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: -36, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        
        orangeImageView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        orangeImageView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        orangeImageView.layer.cornerRadius = 150/2
        orangeImageView.clipsToBounds = true
        
        
        profileImageView.anchor(top: backgroundView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: -75, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 140/2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        view.addSubview(usernameTextField)
        usernameTextField.anchor(top: nil, left: nil, bottom: orangeImageView.topAnchor, right: nil, paddingTop: 36, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(hStackView)
        hStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hStackView.anchor(top: backgroundView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
       
        view.addSubview(logoutButton)
        logoutButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
    }
    
    @objc fileprivate func returnButtonClicked(){
        self.dismiss(animated: true)
        
    }
    
    @objc fileprivate func handleLogout(){
        try? Auth.auth().signOut()
        print("User Signed Out")
        self.dismiss(animated:true)
        let vc = LoginViewController()
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        
    }
    
    @objc fileprivate func editButtonClicked(){
        self.dismiss(animated: true)
        delegate?.pushSettingsController()
        
    }

}
