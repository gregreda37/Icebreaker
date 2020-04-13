//
//  UploadCell.swift
//  TopBox Inc
//
//  Created by Gregory Reda on 9/26/19.
//  Copyright © 2019 TopBox Inc. All rights reserved.
//

import UIKit

class UploadCell: UITableViewCell {

        class UploadTextField: UITextField{
            
            override func textRect(forBounds bounds: CGRect) -> CGRect {
                return bounds.insetBy(dx: 24, dy: 0)
            }
            
            override func editingRect(forBounds bounds: CGRect) -> CGRect {
                return bounds.insetBy(dx: 24, dy: 0)
            }
            
            override var intrinsicContentSize: CGSize{
                return .init(width: 0, height: 44)
            }
        }
        
        let textField: UITextField = {
            let tf = UploadTextField()
            tf.placeholder = "Enter Name"
            return tf
        }()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            addSubview(textField)
            textField.fillSuperview()

            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
