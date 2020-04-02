//
//  ContactCardViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 3/3/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ContactCardViewController: UIView {
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }


    @objc func handleLogin(){
        print("Hi")
    }
    
    let step: Float = 10
    
    var homeController: HomeViewController?
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Greg"
        label.textAlignment = .center
        return label
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .blue
        return iv
    }()


    fileprivate let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24
        v.backgroundColor = .white
        return v
    }()
    
    
    lazy var hStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            titleLabel
            
            ])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 2
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateOut)))
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        self.frame = UIScreen.main.bounds
        self.addSubview(container)
        
        container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.95).isActive = true
        container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.2).isActive = true
        
        container.addSubview(profileImageView)
        profileImageView.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        
        profileImageView.clipsToBounds = true
        
        container.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        hStack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        
        animateIn()
    }

    @objc fileprivate func animateOut(){
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.container.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
            self.alpha = 0
        }) { (complete) in
            if complete {
                self.removeFromSuperview()
                
                print("Nice try")
            }
        }
        
    }
    
    @objc fileprivate func animateIn(){
        self.container.transform = CGAffineTransform(translationX: self.frame.width, y: -self.frame.height)
        self.alpha = 1
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.container.transform = .identity
            self.alpha = 1
        })
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

