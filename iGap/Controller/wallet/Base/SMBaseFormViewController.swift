//
//  SMBaseFormViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Supper class of profile view controllers to handle general actions, such as:
/// keyboard notifications and back button
class SMBaseFormViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SMSignupViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SMSignupViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsetNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        setupNotifications()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsetNotifications()

    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func addBackButton() {
        let btn = UIButton()
        btn.setTitle("back".localized, for: .normal)
        btn.addTarget(self, action: #selector(self.pressedBack), for: .touchUpInside)
        btn.titleLabel?.font = SMFonts.IranYekanBold(18)
        btn.setTitleColor(UIColor(netHex: 0x03a9f4), for: .normal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)

    }
    
    @objc func pressedBack() {
        self.navigationController?.popViewController(animated: true)
        
    }
}
