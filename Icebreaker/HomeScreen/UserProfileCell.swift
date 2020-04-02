//
//  UserProfileCell.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class UserProfileCell: UICollectionViewCell,UIGestureRecognizerDelegate {
    
    var users: User? {
        didSet {
            
            let uid = users?.uid ?? ""
            
            self.usernameTextField.text = self.users?.username ?? ""
            self.timeTextField.text = self.users?.year ?? ""
            self.postTextField.text = users?.major ?? ""
        
            setupProfileImage(uid: uid)
            
        }
    }
    
    fileprivate func setupProfileImage(uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch users", err)
                return
            }
            guard let data = snapshot?.data() else { return }
            let imageUrl1 = data["imageUrl1"] as? String
        
            guard let url = URL(string: imageUrl1 ?? "") else { return }

            URLSession.shared.dataTask(with: url) { (data, response, err) in
                //check for the error, then construct the image using data
                if let err = err {
                    print("Failed to fetch profile image:", err)
                    return
                }

                guard let data = data else { return }

                let image = UIImage(data: data)

                //need to get back onto the main UI thread
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }

                }.resume()
        }

    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "GregFace")
        return iv
    }()

    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.text = "Greg Reda"
        tf.isUserInteractionEnabled = false
        tf.textColor = .white
        tf.font = UIFont.boldSystemFont(ofSize: 16.0)
        tf.contentMode = .scaleAspectFill
        tf.clipsToBounds = true
        return tf
        
    }()
    
    let postTextField: UITextField = {
        let tf = UITextField()
        tf.text = "Computer Science"
        tf.isUserInteractionEnabled = false
        tf.font = UIFont.systemFont(ofSize: 12)
        tf.textColor = .white
        tf.contentMode = .scaleAspectFill
        tf.clipsToBounds = true
        return tf
        
    }()
    
    let timeTextField: UITextField = {
        let tf = UITextField()
        tf.text = "Junior"
        tf.isUserInteractionEnabled = false
        tf.font = UIFont.systemFont(ofSize: 12)
        tf.textColor = .white
        tf.contentMode = .scaleAspectFill
        tf.clipsToBounds = true
        return tf
        
    }()
    
    let dayTextField: UITextField = {
        let tf = UITextField()
        tf.text = "15"
        tf.font = UIFont.systemFont(ofSize: 50)
        tf.isUserInteractionEnabled = false
        tf.textColor = .white
        tf.contentMode = .scaleAspectFill
        tf.clipsToBounds = true
        return tf
        
    }()
    
    let monthTextField: UITextField = {
        let tf = UITextField()
        tf.text = "May"
        tf.textAlignment = .center
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.isUserInteractionEnabled = false
        tf.textColor = .white
        tf.contentMode = .scaleAspectFill
        tf.clipsToBounds = true
        return tf
        
    }()
    
    lazy var dateStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            dayTextField,
            monthTextField,
            ])
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 2
        return sv
    }()
    
    lazy var contentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            usernameTextField,
            postTextField,
            timeTextField
            ])
        sv.axis = .vertical
        sv.spacing = 2
        
        return sv
    }()
    
    var pan: UIPanGestureRecognizer!
    var deleteLabel1: UILabel!
    var deleteLabel2: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)

        addSubview(profileImageView)

        addSubview(profileImageView)
        //profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.clipsToBounds = true


        addSubview(contentStackView)
        contentStackView.anchor(top: topAnchor, left: profileImageView.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 120, paddingBottom: 0, paddingRight: 0, width: 160, height: 80)
        
        
    }

    @objc fileprivate func mapView(){
        //print("showing \(post?.locationAddress ?? "")")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}
