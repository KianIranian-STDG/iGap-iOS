//
//  TextFieldAlertViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/30/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMTextFieldAlertViewController: UIViewController,UITextFieldDelegate {

	
    @IBOutlet weak var pinTextField: UITextField!
	@IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: SMBottomButton!
    @IBOutlet weak var rightButton: SMBottomButton!
	@IBOutlet var forgotPinButton: UIButton!
	
    var message : String?
    var leftButtonTitle:String?
    var rightButtonTitle:String?
	var forgotButtonTitle: String?
    var isForgetButtonHidden : Bool?
	var isCancelButtonEnable: Bool = false
	
    var leftButtonAction: CallBack?
    var rightButtonAction: CallBack?
	var forgotPinAction: SimpleCallBack?
	var payment : Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
		forgotPinButton.setTitle(forgotButtonTitle, for: .normal)
        pinTextField.placeholder = message
        rightButton.enable()
		leftButton.enable()
		
        pinTextField.inputView = LNNumberpad.default()
        pinTextField.becomeFirstResponder()
        pinTextField.delegate = self
		
		if forgotPinAction == nil {
			if !isCancelButtonEnable {
				self.forgotPinButton.isHidden = true
			}
			else {
				self.forgotPinButton.setTitle("no".localized, for: .normal)
				
			}
		}
		
		if payment {
			
			titleLabel.text = title
			pinTextField.placeholder = "۰ ریال".localized
			pinTextField.isSecureTextEntry = false
			
			leftButton.layer.borderColor = UIColor.clear.cgColor
		
			rightButton.colors = [UIColor(netHex: 0x00e676), UIColor(netHex: 0x2ecc71)] //green
			leftButton.colors = [UIColor(netHex: 0x1e96ff), UIColor(netHex: 0x007aff)] //blue

		}
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func leftButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        leftButtonAction?(pinTextField.text)
    }
    @IBAction func rightButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        rightButtonAction?(pinTextField.text)
    }
	@IBAction func forgotPinDidSelect(_ sender: Any) {
		self.dismiss(animated: true, completion: {
			if self.forgotPinAction != nil {
				self.forgotPinAction?()
			}
		})
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
