//
//  CustomTextField.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit

class CustomTextField: UITextField, UITextFieldDelegate {

        let padding: CGFloat
        let height: CGFloat
        
        init(padding: CGFloat, height: CGFloat) {
            self.padding = padding
            self.height = height
            super.init(frame: .zero)
            layer.cornerRadius = height / 2
            backgroundColor = .white
        }

        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: padding, dy: 0)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: padding, dy: 0)
        }
        
        override var intrinsicContentSize: CGSize {
            return .init(width: 0, height: height)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

