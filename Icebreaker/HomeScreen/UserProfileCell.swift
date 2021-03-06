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
            
            self.usernameTextField.text = self.users?.name ?? ""
            
            guard let postImageView = users?.imageUrl1 else {return}
            profileImageView.loadImage(urlString: postImageView)
            
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        return iv
    }()

    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.text = ""
        tf.isUserInteractionEnabled = false
        tf.textColor = .white
        tf.font = UIFont.boldSystemFont(ofSize: 12.0)
        tf.contentMode = .scaleAspectFill
        tf.clipsToBounds = true
        return tf
        
    }()

    var pan: UIPanGestureRecognizer!
    var deleteLabel1: UILabel!
    var deleteLabel2: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)

        addSubview(usernameTextField)
        usernameTextField.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        usernameTextField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true


        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        


        
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
