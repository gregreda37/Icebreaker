//
//  SexCell.swift
//  Icebreaker
//
//  Created by Gregory Reda on 4/10/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit

class SexCell: UITableViewCell {

    let maleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Male", for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        return button
    }()
    let femaleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Female", for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        return button
    }()
    let otherButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.red, for: .normal)
        button.setTitle("Other", for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        return button
    }()
    
    lazy var hStackViewButtons: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            maleButton,
            femaleButton,
            otherButton
            ])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 8
        sv.distribution = .fillEqually
        return sv
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(hStackViewButtons)
        hStackViewButtons.fillSuperview()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

