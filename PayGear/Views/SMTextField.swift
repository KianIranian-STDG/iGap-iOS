//
//  SMTextField.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/16/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Customized UITextFiled to show context of text less than its border from left and right
class SMTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    /// Override superclass method
    ///
    /// - Parameter bounds: TextField text bound
    /// - Returns: CGRect of text bound
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    /// Override superclass method
    ///
    /// - Parameter bounds: TextField placeholder bound
    /// - Returns: CGRect of placeholder bound
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    /// Override superclass method
    ///
    /// - Parameter bounds: TextField editing area
    /// - Returns: CGRect of editable area bound
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }


}

