//
//  SMBottomButtonViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/17/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit


protocol Keyboard {
    func up(hieght : CGFloat?)
    func down(hieght : CGFloat?)
}

class SMScrolableButtonViewController: SMBaseFormViewController {
    
    let background = UIView()
    var delegate : Keyboard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    func setupUI(){
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onBackTapped(gesture:))))
        
        self.background.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(background)
        self.view.sendSubviewToBack(background)
        
        
     
        
        self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.background, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        
    }
    
    
   
    
    
    
    
    @objc func onBackTapped(gesture:UITapGestureRecognizer){
        
        self.view.endEditing(true)
        
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
          let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            delegate?.up(hieght: keyboardHeight)
        }
    }
    
    
    override func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
            delegate?.down(hieght: keyboardHeight)
        }
    }
    
    
    

    
}
